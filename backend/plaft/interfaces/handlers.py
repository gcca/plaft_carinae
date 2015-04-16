# encoding: utf-8
"""
.. module:: plaft.interfaces.handlers
   :synopsis: Handlers.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""
import plaft.application
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
def dispatches_by_customs_agency(handler):
    user = handler.user
    if user:
        handler.render_json(user.customs_agency.get().datastore.pending)
    else:
        handler.status.FORBIDDEN('No hay usuario')


@handler_method('post')
def create(handler): # change name.
    payload = handler.query

    customs_agency = handler.user.customs_agency.get()

    customer = None
    if 'customer' in payload:
        customer_id = payload['customer']
        customer = model.Customer.find(customer_id)
        if not customer:
            handler.status.BAD_REQUEST('No existe el cliente: '
                                       + customer_id)
            return


    dispatch = plaft.application.dispatch.create(payload,
                                                 customs_agency,
                                                 customer)
    handler.render_json({
    'id': dispatch.id,
    'customer': dispatch.customer.id()
    })


@handler_method('put')
def update(handler, dispatch_id=None): # change name.
    payload = handler.query

    customs_agency = handler.user.customs_agency.get()

    customer = None
    if 'customer' in payload:
        customer_id = payload['customer']
        customer = model.Customer.find(customer_id)
        if not customer:
            handler.status.BAD_REQUEST('No existe el cliente: '
                                       + customer_id)
            return

    dispatch = model.Dispatch.find(int(dispatch_id))
    if dispatch:
        plaft.application.dispatch.update(dispatch, payload, customer)
        handler.write_json('{}')
    else:
        handler.status.NOT_FOUND('No existe el despacho con el id: '
                                 + dispatch_id)


@handler_method('post')
def numerate(handler, dispatch_id):
    playload = handler.query

    dispatch = model.Dispatch.find(int(dispatch_id))
    if dispatch:
        plaft.application.dispatch.numerate(dispatch, **playload)

        handler.write_json('{}')
    else:
        handler.status.NOT_FOUND('No existe el despacho con el id: '
                                 + dispatch_id)


@handler_method('post')
def register(handler, dispatch_id):
    q = handler.query

    dispatch = model.Dispatch.find(int(dispatch_id))
    if dispatch:
        plaft.application.dispatch.register(dispatch,
                                      q['country_source'],
                                      q['country_target'])
        handler.write_json('{}')
    else:
        handler.status.NOT_FOUND('No existe el despacho con el id: ' +
                                 dispatch_id)


# vim: et:ts=4:sw=4
