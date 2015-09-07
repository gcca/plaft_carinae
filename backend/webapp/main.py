"""
.. module:: webapp.main
   :synopsis: WSGI Application main.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from webapp2 import WSGIApplication, Route
from webapp2_extras.routes import PathPrefixRoute
from plaft.interfaces import views, handlers, admin
import plaft.config


urls = [
    # Views
    ('/', views.SignIn),
    ('/dashboard', views.Dashboard),
    # Views admin
    ('/admin', admin.views.Admin),
    ('/admin/site', admin.views.AdminSite),

    # Views (no html-json.)
    ('/declaration/pdf/(\\d+)', views.DeclarationPDF),
    ('/declaration/pdfv2/(\\d+)', views.DeclarationPDFv2),

    # Handlers: see RESTful classes

    # Handler methods
    ('/generate_user/(\\d+)', handlers.generate_user),
    ('/update_data', handlers.update_data),
    ('/autocompleters', handlers.autocompleters),

    # Handler Admin
    ('/api/admin/officer', admin.handlers.Officer),
    Route('/api/admin/officer/<id:\\d+>', admin.handlers.Officer),

]


if plaft.config.DEBUG or True:  # TODO: Remove 'or True' on production.
    from plaft.interfaces import debug

    def uri(prefix, handler):
        """URI prefix."""
        prefix = '/' + prefix
        routes = [
            Route(prefix, handler),
            Route(prefix+'/<id:\\d+>', handler)
        ]
        return PathPrefixRoute('/api', routes)

    urls += [
        # Handlers
        uri('operation', debug.Operation),
        uri('datastore', debug.Datastore),
        # Views
        ('/isdebug', debug.IsDebug),
        ('/debug', debug.Debug),
        ('/new-user', debug.NewUsers),
        ('/new-user/(\\d+)', debug.NewUsers),
        ('/users-from-file', debug.UsersFromFile),
        ('/data-to-restore', debug.DataToRestore),
        ('/switch/(\\w+)', debug.SwitchUser),
        # Methods
        ('/restore-data', debug.RestoreData)
    ]


def restful_init():
    """Initialize RESTful URI's."""
    from plaft.interfaces import RESTful, BaseRESTful
    for restful in (restful
                    for _, restful in handlers.__dict__.items()
                    if (
                            isinstance(restful, type) and
                            restful != RESTful and
                            issubclass(restful, RESTful)
                    )):
        prefix = '/' + restful.path
        routes = [
            Route(prefix, restful),
            Route(prefix+'/<id:\\d+>', restful)
        ]

        for subrestful in (subrestful
                           for _, subrestful in restful.__dict__.items()
                           if (
                                   isinstance(subrestful, type) and
                                   issubclass(subrestful, BaseRESTful)
                           )):
            if subrestful.nested:
                nestedprefix = ('%s/%s'
                                % (prefix + ('/<%s_id:\\d+>' % restful.path),
                                   subrestful.path))
                routes.append(Route(nestedprefix, subrestful))
                routes.append(Route(nestedprefix+'/<id:\\d+>', subrestful))
            else:
                subprefix = (prefix + ('/<%s_id:\\d+>' % restful.path)
                             if subrestful.with_id
                             else prefix)
                routes.append(Route('%s/%s' % (subprefix,
                                               subrestful.__name__),
                                    subrestful))

        urls.append(PathPrefixRoute('/api', routes))


def routes_init():
    from plaft.interfaces import RouteHandler, sys

    for route in (route
                  for _, route in sys.__dict__.items()
                  if (
                          isinstance(route, type) and
                          issubclass(route, RouteHandler)
                    )):
        urls.append(('/' + route.__name__, route))


restful_init()
routes_init()
app = WSGIApplication(urls, debug=plaft.config.DEBUG)


# vim: ts=4:sw=4:sts=4:et
