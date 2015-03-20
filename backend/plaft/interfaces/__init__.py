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


class Handler(RequestHandler):
    """Base handler for resquest.

    Implement basic operations to read request and write response data.
    You need override base http methods: GET, POST, PUT, DELETE, etc. E.g.:

    >>> def get(self):
    ...     self.write('<h1>Welcome: cristHian Gz. (gcca)</h1>')

    ..note::

       Maybe you need override methods to write and read object information
       (e.g., html, json, xml, file, pdf, etc.)

    """

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
            r, c = self.CODES[attr]
            self.handler.response.headers['Warning'] = r
            self.handler.response.set_status(c)
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
                return '%i-%i-%i' % (o.year, o.month, o.day)
            if isinstance(o, datetime):
                return '%i-%i-%i %s:%s:%s' % (o.year, o.month, o.day,
                                              o.hour, o.minute, o.second)
            return super(Handler.JSON, self)._default(o)

    rc_status_factory = RCStatusFactory()
    content_type_factory = ContentTypeFactory()

    def write(self, *args, **kwargs):
        """Write response .

        Usually the argument is a string reponse.

        """
        self.response.out.write(*args, **kwargs)

    def write_json(self, serial, rc=None):
        """Write json response.

        Args:
           serial (str): Stringified object.
           rc (str): Request code.

        """
        self.content_type.JSON()
        if rc:
            self.status[rc](ValueError('RC JSON'))
        self.write(serial)

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
        self.user = user_value and model.User.find(int(user_value))

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
    ...         return ('name: "cristHian Gz. (gcca)",'
    ...                 'email: "gcca@gcca.tk",'
    ...                 'user_id: "gcca"')

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

    __args = ''
    """Base str for args."""

    def get(self):
        """GET http method to write controller html."""
        self.write_template()

    def _args(self):
        """Base method to add attributes to controller ``args``."""
        return self.__args

    def write_template(self, args=None):
        """Write template to reponse-out."""
        if not args:
            args = self._args()
        controller = self.__class__.__name__.lower()
        self.write(self.__template % {'controller': controller,
                                      'args': args})

#    def add_arg(self, name, value):

#    def __init__(self, *args, **kwargs):
#        self.arglist = None
#        super(DirectToController, self).__init__(*args, **kwargs)


# vim: et:ts=4:sw=4
