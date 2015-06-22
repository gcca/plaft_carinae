# encoding: utf-8
"""
.. module:: plaft.infrastructure.persistence.base
   :synopsis: Pattern interfaces and support code for the datastore
              implementation.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

import datetime
import abc
import json
from types import GeneratorType

from google.appengine.ext.ndb import model as ndb, query as Q, polymodel
from google.appengine.api.datastore_errors import TransactionFailedError
import plaft.config
from plaft.domain.shared import Entity
from plaft.infrastructure.support import util


class JSONEncoder(json.JSONEncoder):
    """JSON encoder base.

    Need to override ``_default`` method.

    """

    __metaclass__ = abc.ABCMeta

    def __init__(self, **kwargs):
        super(JSONEncoder, self).__init__(**kwargs)
        self.default = self._default

    @abc.abstractmethod
    def _default(self, o):
        """Implement this method in a subclass such that it returns
        a serializable object for ``o``, or calls the base implementation
        (to raise a ``TypeError``).

        For example, to support arbitrary iterators, you could
        implement default like this::

        >>> def default(self, o):
        ...     try:
        ...         iterable = iter(o)
        ...     except TypeError:
        ...         pass
        ...     else:
        ...         return list(iterable)
        ...     # Let the base class default method raise the TypeError
        ...     return JSONEncoder.default(self, o)

        """
        return JSONEncoder.default(self, o)

    @classmethod
    def dumps(cls, obj):
        """Serialize ``obj`` to a JSON formatted ``str``."""
        kwargs = (dict(sort_keys=True, indent=4, separators=(',', ': '))
                  if plaft.config.DEBUG
                  else dict(separators=(',', ':')))
        return unicode(json.dumps(obj,
                                  cls=cls,
                                  check_circular=False,
                                  **kwargs)).decode('utf-8')

    @classmethod
    def loads(cls, s):
        """Deserialize ``s`` (a ``str`` or ``unicode`` instance containing
        a JSON document) to a Python object."""
        return json.loads(s, 'utf-8')


Boolean = ndb.BooleanProperty
Integer = ndb.IntegerProperty
Float = ndb.FloatProperty
Blob = ndb.BlobProperty
Text = ndb.TextProperty
String = ndb.StringProperty
GeoPt = ndb.GeoPtProperty
Pickle = ndb.PickleProperty
Json = ndb.JsonProperty
Key = ndb.KeyProperty
BlobKey = ndb.BlobKeyProperty
DateTime = ndb.DateTimeProperty
Time = ndb.TimeProperty
LocalStructured = ndb.LocalStructuredProperty
Generic = ndb.GenericProperty
Computed = ndb.ComputedProperty
Structured = ndb.StructuredProperty
PolyModel = polymodel.PolyModel


def convert_keys(dct, hist):
    for k in (k for k in dct if k.endswith('_key') and dct[k] is None):
        del dct[k]
        dct[k[:-4]] = None

    for k in (k for k in dct if isinstance(dct[k], ndb.Key)):
        nkey = dct[k]
        if nkey in hist:
            del dct[k]
            dct[k[:-4]] = nkey.id()
        else:
            obj = nkey.get().to_dict()
            convert_keys(obj, hist+(nkey,))
            del dct[k]
            dct[k[:-4]] = obj

    for k in (k for k in dct
              if (isinstance(dct[k], list) and
                  dct[k] and
                  isinstance(dct[k][0], ndb.Key))):
        dct[k[:-4]] = dct[k]
        del dct[k]
        value = dct[k[:-4]]
        i = 0
        for nkey in value:
            obj = nkey.get().to_dict()
            convert_keys(obj, hist+(nkey,))
            dct[k[:-4]][i] = obj
            i += 1


class KeyAccessor(ndb.MetaModel):

    def __new__(mcs, name, bases, dct):
        for k, v in dct.items():
            if isinstance(v, ndb.KeyProperty):
                if v._repeated:
                    accessor = (lambda k:
                                lambda self: [m.get()
                                              for m in getattr(self, k)])(k)
                else:
                    accessor = (lambda k:
                                lambda self: getattr(self, k).get())(k)
                dct[k[:-4]] = property(accessor)
        return super(KeyAccessor, mcs).__new__(mcs, name, bases, dct)


class Model(Entity, ndb.Model):
    """."""

    __metaclass__ = KeyAccessor

    def to_dict(self):
        dct = super(Model, self).to_dict()
        if self.key:
            dct['id'] = self.id
        return dct

    @property
    def dict(self):
        """."""
        dct = self.to_dict()
        convert_keys(dct, (self.key,))
        return dct

    # filter_node = staticmethod(
    #     lambda prop, val: Q.FilterNode(  lint: disable=I0011,W0142
    #         prop, *(('=', val) if not val or '\\' != val[0]
    #                 else ((val[1:2], val[3:]) if '\\' == val[2]
    #                       else ((val[1:3], val[4:]) if '\\' == val[3]
    #                             else (val, None))))))

    @staticmethod
    def filter_node(prop, val):
        if isinstance(val, ndb.Key):  # TODO: remove hardcode for Key
            return Q.FilterNode(prop, '=', val)
        return Q.FilterNode(
            prop, *(('=', val) if not val or '\\' != val[0]
                    else ((val[1:2], val[3:]) if '\\' == val[2]
                          else ((val[1:3], val[4:]) if '\\' == val[3]
                                else (val, None)))))

    @classmethod
    def __all(cls, dto, **filters):
        """."""
        if dto:
            filters = dto
        return cls.query().filter(*(cls.filter_node(*item)
                                    for item in filters.items()))

    @classmethod
    def all(cls, dto=None, **filters):
        """."""
        return cls.__all(dto, **filters).fetch(666)

    @classmethod
    def find(cls, dto_or_id=None, **filters):
        """."""
        return (cls.get_by_id(dto_or_id)
                if isinstance(dto_or_id, (int, long))
                else cls.__all(dto_or_id, **filters).get())

    def store(self):
        """."""
        try:
            return self.put()
        except TransactionFailedError:
            raise IOError

    def delete(self):
        self.key.delete()

    @property
    def id(self):
        """."""
        return self.key.id()

    @classmethod
    def _from(cls, payload):  # parent_key=None):
        if isinstance(cls, ndb.Expando):
            return payload
        properties = {}
        _properties = cls._properties
        for property in _properties:
            if property in payload or property[:-4] in payload:
                prop_type = _properties[property]
                dtype = type(prop_type)
                if dtype is not Key:
                    value = payload[property]

                if dtype is Key:
                    value = payload[property[:-4]]
                    if not value:
                        continue
                    # TODO: hot update nested models
                    if isinstance(value, dict):
                        if 'id' in value:
                            k = ndb.Key(prop_type._kind, int(value['id']))
                            sub = k.get()
                            sub << value
                            sub.store()
                            value = k
                        else:
                            value = ndb.Model._kind_map.get(
                                prop_type._kind).new(value).store()

                    if isinstance(value, (int, long)):
                        value = ndb.Key(prop_type._kind, value)

                elif dtype is Structured and not isinstance(value, list):
                    svalue = {}
                    for sprop in prop_type._modelclass._properties:
                        if value and sprop in value:
                            svalue[sprop] = value[sprop]

                    value = svalue

                elif dtype is Structured and isinstance(value, list):
                    pass
                    # _list = value
                    # for value in _list:
                    #     svalue = {}list_dispatches
                    #     for sprop in prop_type._modelclass._properties:
                    #         if sprop in value:
                    #             svalue[sprop] = value[sprop]
                    #     _list.append(svalue)
                    # value = _list
                else:
                    value = payload[property]
                properties.update({property: value})
        # if 'id' in dict: properties['id'] = dict['id']  # if new entity
        # properties['parent'] = parent_key
        return properties

    def __lshift__(self, dict):
        self.populate(**self._from(dict))

    @classmethod
    def new(cls, dict):
        return cls(**cls._from(dict))


class User(Model):
    """User support."""

    username = ndb.StringProperty(required=True)
    password = ndb.StringProperty(required=True)

    def __init__(self, username=None, password=None, **kwargs):
        password = util.make_pw_hash(username, password)
        super(User, self).__init__(username=username,
                                   password=password,
                                   **kwargs)

    def to_dict(self):
        d = super(User, self).to_dict()
        del d['password']
        return d

    def populate(self, **kwargs):
        if 'password' in kwargs:
            kwargs['password'] = util.make_pw_hash(kwargs['username'],
                                                   kwargs['password'])
        super(User, self).populate(**kwargs)

    @classmethod
    def authenticate(cls, username, password):
        """."""
        user = User.find(username=username)
        if user and util.valid_pw(username, password, user.password):
            return user


class JSONEncoderNDB(JSONEncoder):
    """."""

    def _default(self, o):
        """."""
        if isinstance(o, ndb.Model):
            d = o.dict
            if o.key:
                d['id'] = o.id
            return d
        if isinstance(o, Q.Query):
            return o.fetch(666)
        if isinstance(o, GeneratorType):
            return list(o)
        return JSONEncoder.default(self, o)


# Properties

class Document(Model):
    """Identification document.

    Use value object for entities with identification document.

    Attributes:
        type: A string document type (RUC, DNI, etc).
        number: A string document number.
    """

    type_choices = ['DNI', 'RUC', 'Pasaporte', 'Carné de Extranjería']

    type = String()  # (choices=type_choices)
    number = String()


class DocumentProperty(ndb.StructuredProperty):

    def __init__(self, *args, **kwargs):
        super(DocumentProperty, self).__init__(Document, *args, **kwargs)

    def _validate(self, value):
        return True
        # if not isinstance(value, (int, long)):
        #     raise TypeError('expected an integer, got %s' % repr(value))

    # def _to_base_type(self, value):
    #     return value

    # def _from_base_type(self, value):
    #     return value


class Date(ndb.DateProperty):

    import re
    RE_DATE = re.compile(r'(\d{1,2})[\/-](\d{1,2})[\/-](\d{4})')

    def _validate(self, value):
        if isinstance(value, datetime.date):
            return value
        if isinstance(value, basestring):
            match = self.RE_DATE.match(value)
            if match:
                day, month, year = match.groups()
                value = datetime.date(int(year), int(month), int(day))
                return value
        if value is None or value == '':
            return datetime.date(1970, 1, 1)
        raise TypeError('Bad date from %s: %s.' % (type(value), repr(value)))

    def _db_get_value(self, v, unused_p):
        value = super(Date, self)._db_get_value(v, unused_p)
        if datetime.datetime(1970, 1, 1) == value:
            return None
        return value


# vim: et:ts=4:sw=4
