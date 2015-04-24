# encoding: utf-8
"""
.. module:: plaft.interfaces.handlers
   :synopsis: Handlers.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""
import plaft.application
from plaft.interfaces import RESTHandler, handler_method
from plaft.domain import model
# from plaft import application


class Customer(RESTHandler):
    """Customer RESTful."""


class Dispatch(RESTHandler):
    """Dispatch RESTful."""


class Linked(RESTHandler):
    """Linked RESTful."""


class Declarant(RESTHandler):
    """Declarant RESTful."""


class Operation(RESTHandler):
    """Operation RESTful."""


@handler_method
def pending(handler):
    customs_agency = handler.user.customs_agency.get()
    handler.render_json(
        plaft.application.dispatch.\
        pending_and_accepting(customs_agency)['pending']
    )


@handler_method
def accepting(handler):
    customs_agency = handler.user.customs_agency.get()
    handler.render_json(
        plaft.application.dispatch.\
        pending_and_accepting(customs_agency)['accepting']
    )


@handler_method
def pending_and_accepting(handler):
    customs_agency = handler.user.customs_agency.get()
    handler.render_json(
        plaft.application.dispatch.pending_and_accepting(customs_agency)
    )


@handler_method('post')
def create(handler):
    payload = handler.query

    customs_agency = handler.user.customs_agency.get()

    customer = None
    if 'customer' in payload:
        customer_id = payload['customer']
        customer = model.Customer.find(customer_id)
        if not customer:
            handler.status.\
            BAD_REQUEST('No existe el cliente: ' + customer_id)
            return

    dispatch = plaft.application.dispatch.create(payload,
                                                 customs_agency,
                                                 customer)
    handler.render_json({
        'id': dispatch.id,
        'customer': dispatch.customer.id()
    })


@handler_method('put')
def update(handler, dispatch_id=None):
    payload = handler.query

    customs_agency = handler.user.customs_agency.get()

    customer = None
    if 'customer' in payload:
        customer_id = payload['customer']
        customer = model.Customer.find(customer_id)
        if not customer:
            handler.status.\
            BAD_REQUEST('No existe el cliente: ' + customer_id)
            return

    dispatch = model.Dispatch.find(int(dispatch_id))
    if dispatch:
        plaft.application.dispatch.update(dispatch, payload, customer)
        handler.write_json('{}')
    else:
        handler.status.\
        NOT_FOUND('No existe el despacho con el id: ' + dispatch_id)


@handler_method('post')
def numerate(handler, dispatch_id):
    playload = handler.query

    dispatch = model.Dispatch.find(int(dispatch_id))
    if dispatch:
        plaft.application.dispatch.numerate(dispatch, **playload)

        handler.write_json('{}')
    else:
        handler.status.\
        NOT_FOUND('No existe el despacho con el id: ' + dispatch_id)


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


@handler_method('post')
def accept_dispatch(handler, id=None):
    dispatch = model.Dispatch.find(int(id))
    if dispatch:
        operation = plaft.application.operation.accept(dispatch)
        handler.write_json('{"id":%s}' % operation.id)
    else:
        handler.status.NOT_FOUND('No se halló el desapcho ' + id)


@handler_method('post')
def anexo_seis(handler, dispatch_id):
    playload = handler.query

    dispatch = model.Dispatch.find(int(dispatch_id))
    if dispatch:
        plaft.application.dispatch.anexo_seis(dispatch, **playload)

        handler.write_json('{}')
    else:
        handler.status.\
        NOT_FOUND('No existe el despacho con el id: ' + dispatch_id)


@handler_method
def reporte_operaciones(handler):
    import StringIO
    import xlsxwriter

    operations = model.Operation.all()
    filas = 0

    output = StringIO.StringIO()
    workbook = xlsxwriter.Workbook(output, {'in_memory': True})
    worksheet = workbook.add_worksheet()

    for operation in operations:
        worksheet.write(filas, 0, 'Order')
        worksheet.write(filas, 1, 'Nombre/ Razon social')
        worksheet.write(filas, 2, 'Cantidad de despachos')
        worksheet.write(filas+1, 0, str(operation.id))
        worksheet.write(filas+1, 1, operation.customer.get().name)
        worksheet.write(filas+1, 2, operation.dispatches.__len__())
        worksheet.write(filas+2, 1, 'Lista de despachos')
        worksheet.write(filas+3, 1, 'N. Order')
        worksheet.write(filas+3, 2, 'N. Dam')
        filas = filas + 4
        for despacho in operation.dispatches:
            worksheet.write(filas, 1, despacho.get().order)
            worksheet.write(filas, 2, despacho.get().dam)
            filas = filas+1

    workbook.close()
    output.seek(0)
    handler.response.headers['Content-Type'] = 'application/octotet-stream'
    handler.response.headers['Content-Disposition'] = 'attachment; filename="reporte_operaciones.xlsx"'
    handler.write(output.read())


@handler_method
def generate_user(handler, count):
    count = int(count)
    from string import ascii_letters, digits
    from random import sample

    sources = ascii_letters + digits
    res = [{
            'password': ''.join(sample(sources, 3)),
            'username': ''.join(sample(sources, 4))
           }
           for i in range(count)]
    for r in res:

        agency = model.CustomsAgency(name=r['username'])
        agency.store()
        user = model.User(is_officer=True, customs_agency=agency.key, **r)
        user.store()

        datastore = model.Datastore(customs_agency=agency.key)
        datastore.store()

    handler.render_json(res)

# vim: et:ts=4:sw=4
