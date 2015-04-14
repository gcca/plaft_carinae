# encoding: utf-8
"""
.. module:: plaft.interfaces.handlers
   :synopsis: Handlers.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from plaft.interfaces import RESTHandler, handler_method
from plaft.domain import model
from plaft import application

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
    user = handler.user
    if user:
        handler.render_json(user.customs_agency.get().datastore.pending)
    else:
        handler.status.NOT_FOUND('No hay usuario')


@handler_method('post')
def create_dispatch(handler):
    payload = handler.query

    customs_agency = handler.user.customs_agency.get()

    customer = None
    if payload['customer']:
        customer = model.Customer.find(payload['customer'])

    dispatch = application.dispatch.create(payload,
                                           customs_agency,
                                           customer)

    handler.render_json({
        'id': dispatch.id,
        'customer': customer.id
    })


@handler_method('post')
def register(handler, dispatch_id):
    q = handler.query

    dispatch = Dispatch.find(int(dispatch_id))
    if dispatch:
        application.dispatch.register(dispatch,
                                      q['country_source'],
                                      q['country_target'])
        handler.write_json('{}')
    else:
        handler.status.NOT_FOUND('No existe el despacho con el id: '
                                 + dispatch_id)


# vim: et:ts=4:sw=4
