"""
.. module:: webapp.main
   :synopsis: WSGI Application main.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from webapp2 import WSGIApplication, Route
from webapp2_extras.routes import PathPrefixRoute
from plaft.interfaces import views, handlers, admin
import plaft.config


def uri(prefix, handler):
    prefix = '/' + prefix
    routes = [
        Route(prefix, handler),
        Route(prefix+'/<id:\d+>', handler)
    ]
    return PathPrefixRoute('/api', routes)


urls = [
    # Views
    ('/', views.SignIn),
    ('/dashboard', views.Dashboard),

    # Views (no html-json.)
    ('/declaration/pdf/(\d+)', views.DeclarationPDF),


    # Handlers
    uri('customer', handlers.Customer),
    uri('dispatch', handlers.Dispatch),
    uri('stakeholder', handlers.Stakeholder),
    uri('declarant', handlers.Declarant),

    # Handler methods
    ('/api/income', handlers.create),
    ('/api/income/(\d+)', handlers.update),
    ('/api/dispatch/(\d+)/numerate', handlers.numerate),
    ('/api/dispatch/(\d+)/accept', handlers.accept_dispatch),
    ('/api/dispatch/(\d+)/anexo_seis', handlers.anexo_seis),
    ('/api/customs_agency/list_dispatches', handlers.pending_and_accepting),
    ('/api/operation/list', handlers.list_operation),
    ('/api/reporte_operaciones', handlers.reporte_operaciones),
    ('/generate_user/(\d+)', handlers.generate_user),
    ('/update_data', handlers.update_data),
]


if plaft.config.DEBUG:
    urls += [
        # Views
        ('/debug', views.Debug),
        ('/new-user', views.NewUsers),

        # Handlers
        uri('operation', handlers.Operation),
        uri('datastore', handlers.Datastore),
    ]


app = WSGIApplication(urls, debug=plaft.config.DEBUG)


# vim: ts=4:sw=4:sts=4:et
