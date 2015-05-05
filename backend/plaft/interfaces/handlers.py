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


class Stakeholder(RESTHandler):
    """Stakeholder RESTful."""


class Declarant(RESTHandler):
    """Declarant RESTful."""


class Operation(RESTHandler):
    """Operation RESTful."""


class Datastore(RESTHandler):
    """Datastore RESTful."""


@handler_method
def pending_and_accepting(handler):
    """ (Handler) -> None

    => {
        'pending': [Dispatch],
        'accepting': [Dispatch]
    }
    """
    customs_agency = handler.user.customs_agency
    handler.render_json(
        plaft.application.dispatch.pending_and_accepting(customs_agency)
    )


@handler_method('post')
def create(handler):
    """ (Handler) -> None

    => {
        'id': int,
        'customer': int
    }

    ~> BAD_REQUEST: No ID cliente.
    """
    payload = handler.query

    customs_agency = handler.user.customs_agency

    customer = None
    if 'customer' in payload:
        customer_id = payload['customer']
        customer = model.Customer.find(customer_id)
        if not customer:
            handler.status.BAD_REQUEST('No existe el cliente: ' +
                                       customer_id)
            return

    dispatch = plaft.application.dispatch.create(payload,
                                                 customs_agency,
                                                 customer)
    handler.render_json({
        'id': dispatch.id,
        'customer': dispatch.customer_key.id()
    })


@handler_method('put')
def update(handler, dispatch_id=None):
    """ (Handler) -> None

    => {}

    ~>
        BAD_REQUEST: No existe cliente.
        NOT_FOUND: No existe despacho.
    """
    payload = handler.query
    dispatch = model.Dispatch.find(int(dispatch_id))
    if dispatch:
        dd = plaft.application.dispatch.update(dispatch, payload)
        handler.write_json('{}')
    else:
        handler.status.NOT_FOUND('No existe el despacho con el id: ' +
                                 dispatch_id)


@handler_method('post')
def numerate(handler, dispatch_id):
    """ (Handler) -> None

    => {}

    ~> NOT_FOUND: No existe despacho.
    """
    playload = handler.query

    dispatch = model.Dispatch.find(int(dispatch_id))
    if dispatch:
        plaft.application.dispatch.numerate(dispatch, **playload)

        handler.write_json('{}')
    else:
        handler.status.NOT_FOUND('No existe el despacho con el id: ' +
                                 dispatch_id)


@handler_method('post')
def register(handler, dispatch_id):
    """ (Handler) -> None

    => {}

    ~> NOT_FOUND: No existe despacho.
    """
    query = handler.query

    dispatch = model.Dispatch.find(int(dispatch_id))
    if dispatch:
        plaft.application.dispatch.register(dispatch,
                                            query['country_source'],
                                            query['country_target'])
        handler.write_json('{}')
    else:
        handler.status.NOT_FOUND('No existe el despacho con el id: ' +
                                 dispatch_id)


@handler_method('post')
def accept_dispatch(handler, dispatch_id=None):
    """ (Handler) -> None

    => {'id': int}

    ~> NOT_FOUND: No existe despacho.
    """
    dispatch = model.Dispatch.find(int(dispatch_id))
    if dispatch:
        operation = plaft.application.operation.accept(dispatch)
        handler.write_json('{"id":%s}' % operation.id)
    else:
        handler.status.NOT_FOUND('No se halló el despacho ' + dispatch_id)


@handler_method('post')
def anexo_seis(handler, dispatch_id):
    """ (Handler) -> None

    => {}

    ~> NOT_FOUND: No existe despacho.
    """
    playload = handler.query

    dispatch = model.Dispatch.find(int(dispatch_id))
    if dispatch:
        plaft.application.dispatch.anexo_seis(dispatch, **playload)

        handler.write_json('{}')
    else:
        handler.status.NOT_FOUND('No existe el despacho con el id: ' +
                                 dispatch_id)


@handler_method
def reporte_operaciones(handler):
    """ (Handler) -> None

    => StringIO

    """
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
        worksheet.write(filas+1, 1, operation.customer.name)
        worksheet.write(filas+1, 2, operation.dispatches.__len__())
        worksheet.write(filas+2, 1, 'Lista de despachos')
        worksheet.write(filas+3, 1, 'N. Order')
        worksheet.write(filas+3, 2, 'N. Dam')
        filas = filas + 4
        for despacho in operation.dispatches:
            worksheet.write(filas, 1, despacho.order)
            worksheet.write(filas, 2, despacho.dam)
            filas = filas+1

    workbook.close()
    output.seek(0)
    handler.response.headers['Content-Type'] = 'application/octotet-stream'
    handler.response.headers['Content-Disposition'] = 'attachment;\
                                        filename="reporte_operaciones.xlsx"'
    handler.write(output.read())


@handler_method
def generate_user(handler, count):
    """ (Handler, str) -> None

    => [{
        'password': str,
        'username': str
    }]

    """
    count = int(count)
    from string import ascii_letters, digits
    from random import sample

    sources = ascii_letters + digits
    res = [{'password': ''.join(sample(sources, 3)),
            'username': ''.join(sample(sources, 4))}
           for _ in range(count)]

    for usr in res:
        agency = model.CustomsAgency(name=usr['username'])
        agency.store()
        user = model.User(is_officer=True,
                          customs_agency=agency.key,
                          **usr)
        user.store()

        datastore = model.Datastore(customs_agency=agency.key)
        datastore.store()

    handler.render_json(res)


@handler_method('post')
def update_data(handler):
    """ (Handler) -> None

    => {}

    """
    query = handler.query
    handler.user.username = query['user']
    if query['password']:
        handler.user.populate(username=query['user'],
                              password=query['password'])
    customs = handler.user.customs_agency
    customs.name = query['agency']
    customs.store()
    handler.user.store()

    handler.write_json('{}')


@handler_method
def list_operation(handler):
    """ (Handler) -> None

    => [Operation]

    """
    customs_agency = handler.user.customs_agency
    handler.render_json(
        plaft.application.dispatch.list_operations(customs_agency)
    )


# vim: et:ts=4:sw=4
