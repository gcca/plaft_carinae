# encoding: utf-8
"""
.. module:: plaft.infrastructure.persistence.base
   :synopsis: Pattern interfaces and support code for the datastore
              implementation.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from google.appengine.ext.ndb import model as ndb, query as Q, polymodel
from plaft.domain.shared import Entity
from plaft.application.util import JSONEncoder
from plaft.infrastructure.support import util


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
Date = ndb.DateProperty
Time = ndb.TimeProperty
LocalStructured = ndb.LocalStructuredProperty
Generic = ndb.GenericProperty
Computed = ndb.ComputedProperty
Structured = ndb.StructuredProperty

PolyModel = polymodel.PolyModel


class Model(Entity, ndb.Model):
    """."""

    @property
    def dict(self):
        """."""
        return self.to_dict()

#    filter_node = staticmethod(
#        lambda prop, val: Q.FilterNode(  # pylint: disable=I0011,W0142
#            prop, *(('=', val) if not val or '\\' != val[0]
#                    else ((val[1:2], val[3:]) if '\\' == val[2]
#                          else ((val[1:3], val[4:]) if '\\' == val[3]
#                                else (val, None))))))

    @staticmethod
    def filter_node(prop, val):
        if type(val) is ndb.Key:  # TODO: remove hardcode for Key
            return Q.FilterNode(prop, '=', val)
        return Q.FilterNode(  # pylint: disable=I0011,W0142
                    prop, *(('=', val) if not val or '\\' != val[0]
                            else ((val[1:2], val[3:]) if '\\' == val[2]
                                  else ((val[1:3], val[4:]) if '\\' == val[3]
                                        else (val, None)))))
    @classmethod
    def all(cls, dto=None, **filters):
        """."""
        if dto:
            filters = dto
        # pylint: disable=I0011,W0142
        return cls.query().filter(*(cls.filter_node(*item)
                                    for item in filters.items()))

    @classmethod
    def find(cls, dto_or_id=None, **filters):
        """."""
        return (cls.get_by_id(dto_or_id)
                if isinstance(dto_or_id, (int, long))
                else cls.all(dto_or_id, **filters).get())

    def store(self):
        """."""
        return self.put()

    @property
    def id(self):
        """."""
        return self.key.id()

    @classmethod
    def _from(cls, payload): # parent_key=None):
        if isinstance(cls, ndb.Expando):
            return payload
        properties = {}
        _properties = cls._properties
        for property in _properties:
            if property in payload:
                prop_type = _properties[property]
                dtype = type(prop_type)
                value = payload[property]

                if dtype is Key:
                    if not value: continue
                    # TODO(): hot update nested models
                    if type(value) is dict:
                        value = ndb.Key(prop_type._kind, int(value['id']))
                    if type(value) is (int, long):
                        value = ndb.Key(prop_type._kind, value)
                    continue

                elif dtype is Structured and not type(value) is list:
                    svalue = {}
                    for sprop in prop_type._modelclass._properties:
                        if sprop in value:
                            svalue[sprop] = value[sprop]

                    value = svalue

                elif dtype is Structured and type(value) is list:
                    _list = value
#                    for value in _list:
#                        svalue = {}
#                        for sprop in prop_type._modelclass._properties:
#                            if sprop in value:
#                                svalue[sprop] = value[sprop]
#                        _list.append(svalue)
#                    value = _list

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

    @property
    def dict(self):
        d = super(User, self).dict
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
        if isinstance(o, ndb.Key):
            return o.get()
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

    def _to_base_type(self, value):
        return value

    def _from_base_type(self, value):
        return value




# vim: et:ts=4:sw=4
