"""
.. module:: webapp.main
   :synopsis: WSGI Application main.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from webapp2 import WSGIApplication, Route as R
from plaft.interfaces import views, handlers, admin


app = WSGIApplication([

    # Views
    ('/', views.SignIn),
    ('/dashboard', views.Dashboard),
    ('/debug', views.Debug),

    R('/pdf/<id:\d+>', views.DeclarationPDF),

    # Handlers
    ('/api/customer/by_document', handlers.Customer.by_document),

    ('/api/dispatch', handlers.Dispatch),
    ('/api/dispatch/income', handlers.Dispatch.income),
    R('/api/dispatch/income/<id:\d+>', handlers.Dispatch.income),
    ('/api/dispatch/find', handlers.Dispatch.find),

    R('/api/dispatch/numeration/<id:\d+>', handlers.Numeration),

    R(r'/api/stakeholder/<id:\d+>', handlers.Stakeholder),

    # Admin
    ('/admin/site', admin.views.AdminSite),
    R('/api/admin/customs/<customs_id:\d+>/officer',
        admin.handlers.Officer),
    R('/api/admin/customs/<customs_id:\d+>/officer/<id:\d+>',
        admin.handlers.Officer),
    R('/api/admin/customs/<customs_id:\d+>/employee',
        admin.handlers.Employee),
    R('/api/admin/customs/<customs_id:\d+>/employee/<id:\d+>',
        admin.handlers.Employee),
    R('/api/admin/customs',
        admin.handlers.Customs),
    R('/api/admin/customs/<id:\d+>',
        admin.handlers.Customs)
], debug=True)


# vim: ts=4:sw=4:sts=4:et
