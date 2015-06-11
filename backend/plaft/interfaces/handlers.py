# encoding: utf-8
"""
.. module:: plaft.interfaces.handlers
   :synopsis: Handlers.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""
import plaft.application
from plaft.interfaces import RESTful, handler_method
from plaft.domain import model


class Customer(RESTful):
    """Customer RESTful."""


class Stakeholder(RESTful):
    """Stakeholder RESTful."""

    @RESTful.nested
    class Customer(Customer):
        """Nested Customer RESTful."""


class Declarant(RESTful):
    """Declarant RESTful."""


class User(RESTful):
    """User RESTful."""

    def get(self, id=None):
        self.write_json('{"m":"Are you kidding me?"}')

    def post(self):
        payload = self.query
        customs_agency = self.user.customs_agency
        permissions = payload['permissions']
        permission_id = None

        if permissions:
            permission = model.Permissions()
            permission << permissions
            permission.store()
            permission_id = permission.key

        employee = model.Employee(name=payload['name'],
                                  username=payload['username'],
                                  password=payload['password'],
                                  customs_agency_key=customs_agency.key,
                                  permissions_key=permission_id)
        employee.store()

        customs_agency.employees_key.append(employee.key)
        customs_agency.store()

        self.write_json('{"id":%d}' % employee.id)

    def put(self, id):
        employee = model.Employee.find(int(id))
        employee << self.query
        employee.store()
        self.write_json('{}')

    def delete(self, id):
        self.write_json('{"m":"Are you kidding me?"}')


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


class Customs_Agency(RESTful):

    @RESTful.method
    def list_dispatches(self):
        """ (Handler) -> None

        => {
            'pending': [Dispatch],
            'accepting': [Dispatch]
        }
        """
        customs_agency = self.user.customs_agency
        self.render_json(
            plaft.application.dispatch.pending_and_accepting(customs_agency)
        )


class Dispatch(RESTful):

    def post(self):
        """ (Handler) -> None

        => {
            'id': int,
            'customer': int
        }

        ~> BAD_REQUEST: No ID cliente.
        """
        payload = self.query

        customs_agency = self.user.customs_agency

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
        self.render_json({
            'id': dispatch.id,
            'customer': dispatch.customer_key.id()
        })

    def put(self, id):
        """ (Handler) -> None

        => {}

        ~>
            BAD_REQUEST: No existe cliente.
            NOT_FOUND: No existe despacho.
        """
        payload = self.query
        dispatch = model.Dispatch.find(int(id))
        if dispatch:
            dd = plaft.application.dispatch.update(dispatch, payload)
            self.write_json('{}')
        else:
            self.status.NOT_FOUND('No existe el despacho con el id: ' +
                                  dispatch_id)

    def delete(self, id):
        dispatch = model.Dispatch.find(int(id))

        datastore = dispatch.customs_agency.datastore
        datastore.pending_key.remove(dispatch.key)
        datastore.store()

        dispatch.delete()

        self.write_json('{}')

    @RESTful.method('post')
    def numerate(self, dispatch_id):
        """ (Handler) -> None

        => {}

        ~> NOT_FOUND: No existe despacho.
        """
        playload = self.query

        dispatch = model.Dispatch.find(int(dispatch_id))
        if dispatch:
            plaft.application.dispatch.numerate(dispatch, **playload)

            self.write_json('{}')
        else:
            self.status.NOT_FOUND('No existe el despacho con el id: ' +
                                  dispatch_id)

    @RESTful.method('post')
    def accept(self, dispatch_id):
        """ (Handler) -> None

        => {'id': int}

        ~> NOT_FOUND: No existe despacho.
        """
        dispatch = model.Dispatch.find(int(dispatch_id))
        if dispatch:
            operation = plaft.application.operation.accept(dispatch)
            self.write_json('{"id":%s}' % operation.id)
        else:
            self.status.NOT_FOUND('No se halló el despacho ' + dispatch_id)

    @RESTful.method('post')  # ?
    def anexo_seis(self, dispatch_id):
        """ (Handler) -> None

        => {}

        ~> NOT_FOUND: No existe despacho.
        """
        playload = handler.query

        dispatch = model.Dispatch.find(int(dispatch_id))
        if dispatch:
            plaft.application.dispatch.anexo_seis(dispatch, **playload)

            self.write_json('{}')
        else:
            self.status.NOT_FOUND('No existe el despacho con el id: ' +
                                  dispatch_id)

    @RESTful.method  # get
    def list(self):
        """ (Handler) -> None

        => [Dispatch]
        """
        customs_agency = self.user.customs_agency
        self.render_json(
            plaft.application.dispatch.list_dispatches(customs_agency)
        )


# vim: et:ts=4:sw=4
