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
        import datetime

        query = self.query

        month_report = query['month']
        year_report = query['year']
        customs_agency = self.user.customs_agency
        dispatches = model.Dispatch.all(customs_agency_key=customs_agency.key)
        filas = 3

        output = StringIO.StringIO()
        workbook = xlsxwriter.Workbook(output, {'in_memory': True})
        worksheet = workbook.add_worksheet()
        # NORMAL DISPATCH
        dispatch_format = workbook.add_format({'align': 'center'})
        # DISPATCH IN OPERATION
        operation_format = workbook.add_format({'align': 'center',
                                                'font_color': '#9C0006'})
        # DISPATCH IN OPERATION
        title_format = workbook.add_format({'align': 'center',
                                            'bold': 1,
                                            'font_color': '#9C0006'})
        worksheet.write(2, 1, 'No Fila', title_format)
        worksheet.write(2, 2, 'No Operacion', title_format)
        worksheet.write(2, 3, 'No DAM', title_format)
        worksheet.write(2, 4, 'Modalidad Operacion', title_format)
        worksheet.write(2, 5, 'No Oper. Modalidad', title_format)
        worksheet.write(2, 6, 'Fecha Numeracion', title_format)
        worksheet.write(2, 7, 'DAM FOB US$', title_format)
        idx_operation = 0

        while dispatches:
            dispatch = dispatches[0]
            if dispatch.operation_key:
                excel_format = operation_format
                idx_operation += 1
                if idx_operation <= 9:
                    str_opert = '00%d' % idx_operation
                elif idx_operation <= 99:
                    str_opert = '0%d' % idx_operation
                else:
                    str_opert = str(idx_operation)
                i = 0
                operations = [x for x in dispatches
                          if x.operation_key==dispatch.operation_key]
                if len(operations) is 1:
                    worksheet.write(filas, 1, str_opert, excel_format)
                    worksheet.write(filas, 2, dispatch.order, excel_format)
                    worksheet.write(filas, 3, dispatch.dam, excel_format)
                    worksheet.write(filas, 4, 'U', excel_format)
                    worksheet.write(filas, 5, '', excel_format)
                    worksheet.write(filas, 6, dispatch.numeration_date, excel_format)
                    worksheet.write(filas, 7, dispatch.amount, excel_format)
                    str_opert = ''
                    filas = filas + 1
                    dispatches.remove(dispatch)
                else:
                    for d in operations:
                        i += 1
                        worksheet.write(filas, 1, str_opert, excel_format)
                        worksheet.write(filas, 2, d.order, excel_format)
                        worksheet.write(filas, 3, d.dam, excel_format)
                        worksheet.write(filas, 4, 'M', excel_format)
                        worksheet.write(filas, 5, i, excel_format)
                        worksheet.write(filas, 6, d.numeration_date, excel_format)
                        worksheet.write(filas, 7, d.amount, excel_format)
                        str_opert = ''
                        filas = filas + 1
                        dispatches.remove(d)
            else:
                excel_format = dispatch_format
                str_opert = ''
                worksheet.write(filas, 1, str_opert, excel_format)
                worksheet.write(filas, 2, dispatch.order, excel_format)
                worksheet.write(filas, 3, dispatch.dam, excel_format)
                worksheet.write(filas, 4, 'U', excel_format)
                worksheet.write(filas, 5, '', excel_format)
                worksheet.write(filas, 6, dispatch.numeration_date, excel_format)
                worksheet.write(filas, 7, dispatch.amount, excel_format)
                dispatches.remove(dispatch)
                filas = filas + 1
        workbook.close()
        output.seek(0)
        ztime = datetime.datetime.utcnow()
        name_file = "Reporte MENSUAL(%s).xlsx" % (ztime.strftime('%d / %m / %Y'))
        self.response.headers['Content-Type'] = 'application/octotet-stream'
        self.response.headers['Content-Disposition'] = 'attachment;\
                                            filename="%s"' %(name_file)
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
