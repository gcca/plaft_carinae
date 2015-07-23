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


class Declarant(RESTful):
    """Declarant RESTful."""


class Officer(RESTful):
    """Officer RESTful."""

    def post(self):
        payload = self.query
        agency_name = payload['agency']
        username = payload['username']
        password = payload['password']
        officer_name = payload['name']
        customs_agency = model.CustomsAgency(name=agency_name)
        customs_agency.store()

        permission = model.Permissions(modules=['WEL-HASH',
                                                'NUM-HASH',
                                                'ANEXO2-HASH',
                                                'INCOME-HASH',
                                                'OPLIST-HASH'],
                                       signals=[])
        permission.store()

        datastore = model.Datastore(customs_agency_key=customs_agency.key)
        datastore.store()

        officer = model.Officer(username=username,
                                password=password,
                                name=officer_name,
                                customs_agency_key=customs_agency.key,
                                permissions_key=permission.key)
        officer.store()

        customs_agency.officer_key = officer.key
        customs_agency.store()
        self.render_json({'id': customs_agency.id})

    def put(self, id):
        payload = self.query
        agency_name = payload['agency']
        customs_agency = model.CustomsAgency.find(int(id))
        customs_agency.name = agency_name
        customs_agency.store()

        del payload['agency']

        officer = customs_agency.officer
        officer << payload
        officer.store()

        self.write_json('{}')

    def delete(self, id):
        customs_agency = model.CustomsAgency.find(int(id))
        customs_agency.delete()


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
def autocompleters(handler):
    autocompleter = {
        'stakeholder': {stk.slug: stk.id for stk in model.Stakeholder.all()},
        'declarant': {dcl.slug: dcl.id for dcl in model.Declarant.all()}
    }

    handler.render_json(autocompleter)


class Operation(RESTful):
    """Operation RESTful handler."""

    @RESTful.method
    def operations(self):
        """ (Handler) -> None

        => [Operation]

        """
        customs_agency = self.user.customs_agency
        self.render_json(
            plaft.application.dispatch.list_operations(customs_agency)
        )

    @RESTful.method
    def monthly_report(self):
        """ (Handler) -> None

        => StringIO

        """
        import StringIO
        import xlsxwriter
        from datetime import datetime

        customs_agency = self.user.customs_agency
        operations = plaft.application.dispatch.list_operations(customs_agency)
        filas = 3

        output = StringIO.StringIO()
        workbook = xlsxwriter.Workbook(output, {'in_memory': True})
        worksheet = workbook.add_worksheet()
        worksheet.set_column('B:B', 15)
        worksheet.set_column('C:C', 5)
        worksheet.set_column('D:D', 5)
        worksheet.set_column('E:E', 10)
        worksheet.set_column('F:F', 22)
        worksheet.set_column('G:H', 5)
        worksheet.set_column('I:I', 10)
        worksheet.set_column('J:J', 15)
        # NORMAL DISPATCH
        dispatch_format = workbook.add_format({'align': 'center',
                                               'border': 1})
        # DISPATCH IN OPERATION
        operation_format = workbook.add_format({'align': 'center',
                                                'font_color': '#9C0006',
                                                'border': 1})
        # DISPATCH IN OPERATION
        title_format = workbook.add_format({'align': 'center',
                                            'bold': 1,
                                            'font_color': '#9C0006',
                                            'border': 1})
        worksheet.write(2, 1, 'No Orden', title_format)
        worksheet.write(2, 2, 'Rg.', title_format)
        worksheet.write(2, 3, 'No F.', title_format)
        worksheet.write(2, 4, 'No Reg.', title_format)
        worksheet.write(2, 5, 'DAM', title_format)
        worksheet.write(2, 6, 'M.O.', title_format)
        worksheet.write(2, 7, 'N.M.', title_format)
        worksheet.write(2, 8, 'FOB US$', title_format)
        worksheet.write(2, 9, 'F. Numeracion', title_format)

        for operation in operations:
            for i in range(len(operation.dispatches)):
                dispatch = operation.dispatches[i]
                index = operation.num_modalidad[i]
                excel_format = dispatch_format
                amount = float(dispatch.amount)
                if amount > 10000:
                    excel_format = operation_format
                worksheet.write(filas, 1, dispatch.order, excel_format)
                worksheet.write(filas, 2, dispatch.regime.code, excel_format)
                worksheet.write(filas, 3, operation.row_number, excel_format)
                worksheet.write(filas, 4, operation.register_number,
                                excel_format)
                worksheet.write(filas, 5, dispatch.dam, excel_format)
                worksheet.write(filas, 6, operation.modalidad,
                                excel_format)
                worksheet.write(filas, 7, '%s' % index, excel_format)
                worksheet.write(filas, 8, "{0:.2f}".format(amount),
                                excel_format)
                worksheet.write(filas, 9,
                                dispatch.numeration_date.strftime('%d/%m/%Y'),
                                excel_format)
                filas = filas + 1
        workbook.close()
        output.seek(0)
        ztime = datetime.now().strftime("%B")
        name_file = "Reporte MENSUAL-(%s).xlsx" % ztime
        self.response.headers['Content-Type'] = 'application/octotet-stream'
        self.response.headers['Content-Disposition'] = 'attachment;\
                                            filename="%s"' % name_file
        self.write(output.read())


class Customs_Agency(RESTful):
    """Custom Agency RESTful handler."""

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

    @RESTful.method
    def officers(self):
        users = [customs.officers for customs in model.CustomsAgency.all()]
        self.render_json(users)


class Dispatch(RESTful):
    """Dispatch RESTful handler."""

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
                self.status.BAD_REQUEST('No existe el cliente: ' +
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
            plaft.application.dispatch.update(dispatch, payload)
            self.write_json('{}')
        else:
            self.status.NOT_FOUND('No existe el despacho con el id: ' +
                                  id)

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

            self.render_json('{}')
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
            plaft.application.operation.accept(dispatch)
            self.write_json('{}')
        else:
            self.status.NOT_FOUND('No se halló el despacho ' + dispatch_id)

    @RESTful.method('post')
    def reject(self, dispatch_id):
        """ (Handler) -> None

        => {'id': int}

        ~> NOT_FOUND: No existe despacho.
        """
        dispatch = model.Dispatch.find(int(dispatch_id))
        if dispatch:
            plaft.application.operation.reject(dispatch)
            self.write_json('{}')
        else:
            self.status.NOT_FOUND('No se halló el despacho ' + dispatch_id)

    @RESTful.method('post')
    def accept_anexo(self, dispatch_id):
        dispatch = model.Dispatch.find(int(dispatch_id))
        datastore = dispatch.customs_agency.datastore
        datastore.pending_key.remove(dispatch.key)
        datastore.accepting_key.append(dispatch.key)
        datastore.store()
        self.write_json('{}')

    @RESTful.method('post')  # ?
    def anexo_seis(self, dispatch_id):
        """ (Handler) -> None

        => {}

        ~> NOT_FOUND: No existe despacho.
        """
        playload = self.query

        dispatch = model.Dispatch.find(int(dispatch_id))
        if dispatch:
            plaft.application.dispatch.anexo_seis(dispatch, **playload)

            self.write_json('{}')
        else:
            self.status.NOT_FOUND('No existe el despacho con el id: ' +
                                  dispatch_id)

    @RESTful.method('post')
    def alerts(self, dispatch_id):
        """ (Handler) -> None

        => {}

        ~> NOT_FOUND: No existe despacho.
        """
        payload = self.query

        dispatch = model.Dispatch.find(int(dispatch_id))
        if dispatch:
            del payload['stakeholders']
            dispatch << payload
            dispatch.store()
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
