# encoding: utf-8
"""
.. module:: plaft.interfaces.handlers
   :synopsis: Handlers.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from plaft.interfaces import RESTHandler, handler_method
from plaft.domain import model


class Customer(RESTHandler):
    """Customer RESTful."""


class Dispatch(RESTHandler):
    """Dispatch RESTful."""


class Linked(RESTHandler):
    """Linked RESTful."""


class Declarant(RESTHandler):
    """Declarant RESTful."""


@handler_method
def pending_dispatches(handler):
    handler.render_json(handler.user.customs_agency.get().datastore.pending)


@handler_method('post')
def create_dispatch(handler):
    q = handler.query

    customs_agency = handler.user.customs_agency.get()
    dispatch = Dispatch.new(q)

    customer = None
    if q['customer']:
        customer = Customer.find(q['customer'])

    application.dispatch.create(dispatch, customs_agency, customer)

    handler.render_json({
        'id': dispatch.id,
        'customer': customer.id
    })


# vim: et:ts=4:sw=4
