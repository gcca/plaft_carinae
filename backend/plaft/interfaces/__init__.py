"""
.. module:: plaft.interfaces
   :synopsis: Interfaces layer. Base classes.

.. todo:: disengage infrastructure.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from datetime import datetime, date
from collections import namedtuple
from webapp2 import RequestHandler
from plaft.domain import model
from plaft.infrastructure.support import util


def login_required(method):
    """Handler method decorator."""
    def wrapper(self, *args, **kargs):
        """check authenticated user."""
        return (method(self, *args, **kargs)
                if self.user
                else (self.status.FORBIDDEN('restricted-access')
                      if '/api/' in self.request.url
                      else self.redirect('/?restricted-access')))
    return wrapper


class LoginRequired(type):
    """Metaclass to set default protected method for authentication."""

    def __new__(mcs, name, bases, dct):
        # TODO: Improve method to decide when apply login validation
        #       to a concret handler.
        if name == 'SignIn':  # (-o-) HARDCODE: SignIn
            def without_user(self, *args, **kwargs):
                """Disable check user."""
                super(self.__class__, self).initialize(*args, **kwargs)
                self.user = True
            dct['initialize'] = without_user

        if name not in ('Handler', 'Debug'):  # (-o-) HARDCODE: Debug
            for method in ('get', 'post', 'put', 'delete'):
                if method in dct:
                    dct[method] = login_required(dct[method])

        return super(LoginRequired, mcs).__new__(mcs, name, bases, dct)


class Handler(RequestHandler):

    # __metaclass__ = LoginRequired

    """Base handler for resquest.

    Implement basic operations to read request and write response data.
    You need override base http methods: GET, POST, PUT, DELETE, etc. E.g.:

    >>> def get(self):
    ...     self.write('<h1>Welcome: cristHian Gz. (gcca)</h1>')

    ..note::

       Maybe you need override methods to write and read object information
       (e.g., html, json, xml, file, pdf, etc.)

    """

    _user_model = model.User


    class BaseFactory(object):
        """Base HTTP attribute setter factory."""

        def __init__(self):
            self.handler = None

        def __call__(self, handler):
            self.handler = handler
            return self

        def __getattr__(self, attr):
            return self.nothing

        @staticmethod
        def nothing():
            """Do nothing."""
            pass

        def write_error(self, msg=None):
            """Error message to response."""
            if msg:
                self.handler.write_json('{"e":"%s"}' % msg)

    class RCStatusFactory(BaseFactory):
        """Status RC factory."""

        _rc = namedtuple('CODE', 'r c')

        CODES = dict(ALL_OK=_rc('OK', 200),
                     CREATED=_rc('Created', 201),
                     ACCEPTED=_rc('Accepted', 202),
                     DELETED=_rc('', 204),
                     BAD_REQUEST=_rc('Bad Request', 400),
                     UNAUTHORIZED=_rc('Unauthorized', 401),
                     NOT_PAYMENT=_rc('Payment Required', 402),
                     FORBIDDEN=_rc('Forbidden', 403),
                     NOT_FOUND=_rc('Not Found', 404),
                     NOT_ACCEPTABLE=_rc('Not acceptable', 406),
                     DUPLICATE_ENTRY=_rc('Conflict/Duplicate', 409),
                     NOT_HERE=_rc('Gone', 410),
                     INTERNAL_ERROR=_rc('Internal Error', 500),
                     NOT_IMPLEMENTED=_rc('Not Implemented', 501),
                     THROTTLED=_rc('Throttled', 503))

        def __getattr__(self, attr):
            req, cod = self.CODES[attr]
            self.handler.response.headers['Warning'] = req
            self.handler.response.set_status(cod)
            return self.write_error

    class ContentTypeFactory(BaseFactory):
        """Content type factory."""

        HDRS = dict(JSON='application/json; charset=UTF-8',
                    DOWN='application/force-download')

        def __getattr__(self, attr):
            self.handler.response.headers['Content-Type'] = self.HDRS[attr]
            return self.nothing

    _sign = ''.join(chr(33 + ((ord(c) + 14) % 94))
                    if 33 <= ord(c) <= 126 else c
                    for c in '4C:DEw:2? vK] W8442X  \\  9EEAi^^8442]E<')

    # JSON encoder for buitins types

    class JSON(model.JSONEncoder):
        """JSON encoder for local builtin types."""

        def _default(self, o):
            """Serialize ``o``."""
            if isinstance(o, date):
                day = o.day if o.day > 9 else '0' + str(o.day)
                month = o.month if o.month > 9 else '0' + str(o.month)
                return '%s/%s/%s' % (day, month, o.year)

            if isinstance(o, datetime):
                day = o.day if o.day > 9 else '0' + str(o.day)
                month = o.month if o.month > 9 else '0' + str(o.month)
                return '%s/%s/%s %s:%s:%s' % (day, month, o.year,
                                              o.hour, o.minute, o.second)
            return super(Handler.JSON, self)._default(o)

    rc_status_factory = RCStatusFactory()
    content_type_factory = ContentTypeFactory()

    def write(self, *args, **kwargs):
        """Write response .

        Usually the argument is a string reponse.

        """
        self.response.out.write(*args, **kwargs)

    def write_json(self, serial, _rc=None):
        """Write json response.

        Args:
           serial (str): Stringified object.
           _rc (str): Request code.

        """
        self.content_type.JSON()
        if _rc:
            self.status[_rc](ValueError('RC JSON'))
        self.write(serial)

    def write_file(self, filepayload, name=None):
        """"Write file response."""
        if name:
            self.response.headers['Content-Disposition'] = \
                str('attachment; filename=' + name)
        self.content_type.DOWN()
        self.write(filepayload)

    def write_value(self, name, value):
        """Set cookie parameter.

        Args:
           name (str): Cookie name.
           value (str): Cookie value.

        """
        self.response.set_cookie(name, util.make_secure(value), path='/')

    def read_value(self, name):
        """Get cookie parameter.

        Args:
           name (str): Cookie name.

        Returns:
           str.   Cookie value.

        """
        value = self.request.cookies.get(name)
        return value and util.check_secure(value)

    def render_json(self, obj):
        """Render json response."""
        self.write_json(self.JSON.dumps(obj))

    @property
    def query(self):
        """Deserialize ``self.body`` (``str`` or ``unicode`` JSON document)
        to a ``dict``."""
        body = self.request.body
        return self.JSON.loads(body) if body else dict(self.request.GET)

    @property
    def content_type(self):
        """Set response content type."""
        return self.content_type_factory(self)

    @property
    def status(self):
        """Set response rc status."""
        return self.rc_status_factory(self)

    def login(self, user):
        """Set coookie to authorization."""
        self.write_value('u', str(user.id))

    def logout(self):
        """Remove cookie to authorization."""
        self.response.headers.add_header('Set-Cookie', 'u=; Path=/')

    def initialize(self, *args, **kwargs):
        super(Handler, self).initialize(*args, **kwargs)
        self.response.headers['by'] = self._sign
        user_value = self.read_value('u')
        self.user = user_value and self._user_model.find(int(user_value))

    def __init__(self, *args, **kwargs):
        self.user = None
        super(Handler, self).__init__(*args, **kwargs)


# Generic views

class DirectToController(Handler):
    """Create response from controller template.

    Inherited classes need override the method ``json_args`` to print
    a string with json attribtues to client side.

    Also you need to set the subclass name with the controller name
    for this view. The lower case string of class name is used by default.

    E.g., to create a view for welcome page:

    >>> class Welcome(DirectToController):
    ...
    ...
    ...     # if you need print attributes to args
    ...     def _args(self):
    ...         self.add_arg('name', 'cristHian Gz. (gcca)')
    ...         self.add_arg('code', 713)
    ...         self.add_arg('list', [1, 2, '3'])
    ...         self.add_arg('obj', {'level': 3, 'partners': ['1', '2']})
    ...         self.add_arg('variant': [
    ...             1,
    ...             '2',
    ...             {
    ...                 'name': 'gcca',
    ...                 'code': 713
    ...             },
    ...             [1, 2, '3']
    ...         ])
    ...     # if you nedd attributes lists
    ...         self.add_list('roles', ['a', 'b', 'c', 'd'])

    """

    __template = (
        '<html>'
        '<head>'
        '<meta name="viewport" content="width=device-width,'
        ' initial-scale=1.0, maximum-scale=1.0, user-scalable=no">'
        '<meta name="description"'
        ' content="prevencion de lavado de activos'
        ' y financiamiento del terrorismo">'
        '<meta name="author"'
        'content="Cristhian Alberto Gonzales Castillo">'
        '<meta charset="UTF-8">'
        '<link rel="stylesheet" href="/webapp/%(controller)s.css">'
        '<title>PLAFT-sw</title>'
        '</head>'
        '<body>'
        '<script>window.plaft={%(args)s}</script>'
        '<script src="/webapp/%(controller)s.js"></script>'
        '</body>'
        '</html>'
    )
    """Base template to HTML code."""

    def get(self):
        """GET http method to write controller html."""
        self._args()
        self.write_template()

    def add_list(self, name, value):
        """Base method to add lists in ``args``."""
        self.lists[name] = value

    def add_arg(self, name, value):
        """Base method to add attributes to controller ``args``."""
        self.args.append((name, value))

    def _args(self):
        """Callback to add controller args."""

    def write_template(self, args=None):
        """Write template to reponse-out."""
        self.args.append(('lists', self.lists))
        if not args:
            args = ','.join('"%s":%s' % (k, self.JSON.dumps(v))
                            for k, v in self.args)
        controller = self.__class__.__name__.lower()
        self.write(self.__template % {'controller': controller,
                                      'args': args})

    def __init__(self, *args, **kwargs):
        self.args = []
        self.lists = {}
        super(DirectToController, self).__init__(*args, **kwargs)


# Abstract HTTP methods

def handler_method(method='get'):
    """Method to handler class."""
    if isinstance(method, str):
        def wrapper(func):
            """Create class with handler specific method."""
            return type('HandlerMethod', (Handler,), {method: func})
        return wrapper
    return type('HandlerMethod', (Handler,), {'get': method})


# RESTful handler

class MetaRESTful(type):
    """Ensure basic class attributes."""

    def __init__(cls, name, *args):
        if 'RESTful' != name:
            cls.path = name.lower()

            if not cls._model:
                try:
                    cls._model = getattr(model, name, None)
                except AttributeError:
                    raise AttributeError(
                        '{"e":"No RESTHandler model class name:'
                        ' %s."}' % name)

        super(MetaRESTful, cls).__init__(name, *args)


class BaseRESTful(Handler):
    """Base RESTful handlers with nested entities and extra methods.

    TODO: Improve (created) method to collect uri's.
    """

    _model = None
    path = None
    nested = False  # see nested below

    def get(self, id=None):
        """READ or LIST."""
        if id:
            try:
                instance = self._model.find(int(id))
            except ValueError:
                self.status.BAD_REQUEST('Bad id %s' % id)
            else:
                if instance:
                    self.render_json(instance)
                else:
                    self.status.NOT_FOUND('Not found by id %s' % id)

        else:
            instances = list(self._model.all(**self.query))
            self.render_json(instances)
            # params = self.request.GET.items()
            # params = ', '.join('%s=%s' % pair for pair in params)
            # self.status.NOT_FOUND('Not found with %s' % params)

    def post(self):
        """CREATE."""
        query = self.query

        if query:
            if isinstance(query, list):  # create batch
                instances = []
                try:
                    for dto in query:
                        instance = self._model.new(dto)
                        instance.store()
                        instances.append(instance)
                except IOError:
                    for instance in instances:
                        instance.delete()
                    self.status.INTERNAL_ERROR('Internal store')
                else:
                    self.render_json(instance.id for instance in instances)
                    self.incr()
            else:  # create single
                instance = self._model.new(query)
                try:
                    instance.store()
                except IOError:
                    self.status.INTERNAL_ERROR('Internal batch store')
                else:
                    self.write_json('{"id":%d}' % instance.id)
                    self.incr()
                    return instance
        else:
            self.status.BAD_REQUEST('No query')

    def put(self, id):
        """EDIT."""
        try:
            instance = self._model.find(int(id))
        except ValueError:
            self.status.BAD_REQUEST('Bad id %s' % id)
        else:
            if instance:
                query = self.query
                if query:
                    instance << query
                    try:
                        instance.store()
                    except IOError:
                        self.status.INTERNAL_ERROR('Internal store')
                    else:
                        self.write_json('{}')
                        self.incr()
                else:
                    self.status.BAD_REQUEST('No query')
            else:
                self.status.NOT_FOUND('Not found by id %s' % id)

    def delete(self, id):
        """REMOVE."""
        try:
            instance = self._model.find(int(id))
        except ValueError:
            self.status.BAD_REQUEST('Bad id %s' % id)
        else:
            if instance:
                instance.delete()
            else:
                self.status.NOT_FOUND('Not found by id %s' % id)

    def incr(self):
        from google.appengine.api import memcache
        counter = memcache.get('iocounter')
        if counter is None:
            counter = 0
            memcache.add('iocounter', counter)
        else:
            memcache.incr('iocounter')


class RESTful(BaseRESTful):
    """RESTful handler."""

    __metaclass__ = MetaRESTful

    @staticmethod
    def nested(cls_restful):
        """Nested RESTful handler."""
        cls_restful.nested = True
        return cls_restful

    @staticmethod
    def method(method_or_fn):
        """RESTful handler class from method."""
        if isinstance(method_or_fn, str):  # method
            def wrapper(func):
                """Create class with RESTful specific method."""
                return type(func.func_name,
                            (BaseRESTful,),
                            {method_or_fn: func,
                             'with_id': func.func_code.co_argcount > 1})
            return wrapper
        return type(method_or_fn.func_name,  # fn
                    (BaseRESTful,),
                    {'get': method_or_fn,
                     'with_id': method_or_fn.func_code.co_argcount > 1})

    @staticmethod
    def staticmethod(method_or_fn):
        """RESTful handler class from static method."""
        if isinstance(method_or_fn, str):  # method
            def wrapper(fn):
                """Create class with RESTful specific method."""
                return type(fn.func_name,
                            (BaseRESTful,),
                            {method_or_fn: fn,
                             '_type': 1,
                             'varnames': fn.func_code.co_varnames[1:]})
            return wrapper
        return type(method_or_fn.func_name,  # fn
                    (BaseRESTful,),
                    {'get': method_or_fn,
                     '_type': 1,
                     'varnames': method_or_fn.func_code.co_varnames[1:]})


# Routes for HTTP methods

class RouteHandler(Handler):  # Improve with ABC
    """Dummy for routes."""


def route(method='get'):
    """Method to handler class."""
    if isinstance(method, str):
        def wrapper(fn):
            """Create class with handler specific method."""
            return type(fn.func_name, (RouteHandler,), {method: fn})
        return wrapper
    return type(method.func_name, (RouteHandler,), {'get': method})


# vim: et:ts=4:sw=4
