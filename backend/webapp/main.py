"""
.. module:: webapp.main
   :synopsis: WSGI Application main.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from webapp2 import WSGIApplication, Route
from webapp2_extras.routes import PathPrefixRoute
from plaft.interfaces import views, handlers, admin


def uri(prefix, handler):
    prefix = '/' + prefix
    routes = [
        Route(prefix, handler),
        Route(prefix+'/<id:\d+>', handler)
    ]
    return PathPrefixRoute('/api', routes)


app = WSGIApplication([

    # Views
    ('/', views.SignIn),
    ('/dashboard', views.Dashboard),
    ('/debug', views.Debug),

    ('/declaration/pdf/(\d+)', views.DeclarationPDF),

    # Handlers
    uri('customer', handlers.Customer),
    uri('dispatch', handlers.Dispatch),
    uri('linked', handlers.Linked),
    uri('declarant', handlers.Declarant),

    # Handler methods
    ('/api/income/create', handlers.create), # change name
    ('/api/income/create/(\d+)', handlers.update),
    ('/api/dispatch/(\d+)/numerate', handlers.numerate),
    ('/api/customs_agency/(\d+)/list_dispatches',
                handlers.dispatches_by_customs_agency),

    ('/api/dispatch/(\d+)/accept', handlers.accept_dispatch),

    # # Admin
    # ('/admin/site', admin.views.AdminSite),
    # R('/api/admin/customs/<customs_id:\d+>/officer',
    #     admin.handlers.Officer),
    # R('/api/admin/customs/<customs_id:\d+>/officer/<id:\d+>',
    #     admin.handlers.Officer),
    # R('/api/admin/customs/<customs_id:\d+>/employee',
    #     admin.handlers.Employee),
    # R('/api/admin/customs/<customs_id:\d+>/employee/<id:\d+>',
    #     admin.handlers.Employee),
    # R('/api/admin/customs',
    #     admin.handlers.Customs),
    # R('/api/admin/customs/<id:\d+>',
    #     admin.handlers.Customs)
 ], debug=True)


# vim: ts=4:sw=4:sts=4:et
