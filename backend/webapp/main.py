"""
.. module:: webapp.main
   :synopsis: WSGI Application main.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from webapp2 import WSGIApplication, Route, RequestHandler
from webapp2_extras.routes import PathPrefixRoute
from plaft.interfaces import views, handlers, admin
import plaft.config


urls = plaft.config.urls

urls += [
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
    ('/api/admin/billing', admin.handlers.Billing),
    Route('/api/admin/billing/<id:\\d+>', admin.handlers.Billing),
    ('/api/admin/list-billing', admin.handlers.ListBilling),
    ('/api/admin/customs_agency', admin.handlers.CustomsAgency),
    Route('/api/admin/customs_agency/<id:\\d+>', admin.handlers.CustomsAgency),

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
    # TODO: HARDCODE remove
    restfuls_methods = handlers.__dict__.items()
    if plaft.config.DEBUG or True:
        from plaft.interfaces import debug
        restfuls_methods = restfuls_methods + debug.__dict__.items()

    for restful in (restful
                    for _, restful in restfuls_methods
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

            # HARDCODE: `type`:attribute to define type of nested resource
            subtype = getattr(subrestful, '_type', None)
            # TODO: no `getattr`
            if subtype:
                if 1 == subtype:
                    subprefix = [prefix, subrestful.__name__]
                    for varname in subrestful.varnames:
                        subprefix.append('<%s>' % varname)
                    subprefix = '/'.join(subprefix)
                    routes.append(Route(subprefix, subrestful))
                    continue

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


class Urls(RequestHandler):

    def get(self):
        def htos(h):
            return '%s&nbsp;&nbsp;&nbsp;&nbsp;</td><td>%s' % (
                (k for k in h.__dict__.keys() + [' ']
                 if k in ('get', 'post', 'put', 'delete', ' '))
                .next().upper(),
                repr(h)[25:-2])

        def esc(s):
            s = s.replace('<', '&lt;')
            s = s.replace('>', '&gt;')
            s = s.replace(' ', '&nbsp;')
            # s = s.replace('', '&;')
            return s

        html = [
            '<html>'
            '<head><style>'
            'td:first-child {padding-right:50px}'
            '</style></head>'
            '<body>'
            '<table>'
        ]
        for url in urls:
            if isinstance(url, tuple):
                html.append(
                    '<tr><td>%s</td><td>%s</td></tr>'
                    % (esc(url[0]), htos(url[1])))
            elif isinstance(url, PathPrefixRoute):
                html.append('<tr><td>%s</td><td></td></tr>' % url.prefix)
                for sub in url.routes:
                    html.append(
                        '<tr><td>&nbsp&nbsp;&nbsp&nbsp%s</td><td>%s</td></tr>'
                        % (esc(sub.template[4:]),
                           htos(sub.handler)))
            else:
                html.append(
                    '<tr><td>%s</td><td>%s</td></tr>' % (
                        esc(url.template[4:]), htos(url.handler)))
            html.append('<tr><td>&nbsp;</td></tr>')
        html.append('</table></body></html>')
        self.response.out.write(''.join(html))
urls.append(('/urls', Urls))


app = WSGIApplication(urls, debug=plaft.config.DEBUG)


# vim: ts=4:sw=4:sts=4:et
