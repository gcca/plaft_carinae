# encoding: utf-8

from __future__ import unicode_literals
import random
from plaft.domain.model import (Dispatch, Business, Person, Customer,
                                CodeName, Alert, User, Permissions,
                                Employee, Operation, CustomsAgency,
                                Datastore, Officer, Worker,
                                KnowledgeWorker)
from plaft.application.util import data_generator
from datetime import datetime, timedelta
from string import digits

jurisdictions = data_generator.jurisdictions.jurisdictions
stakeholders = data_generator.stakeholders.stakeholders
regimes = data_generator.regimes.regimes
declarants = data_generator.declarants.declarants

## UTILS

TYPE2NUMBER = {
    'ruc': 9,
    'dni': 7
}


DOCNUMS = ('0', '1', '2', '3', '4',
           '5', '6', '7', '8', '9',
           '0', '1', '2', '3', '4',
           '5', '6', '7', '8', '9')


def pick_document_number_by(document_type):
    TYPE = {
        'ruc': '20',
        'dni': '10'
    }
    return '%s%s' % (TYPE[document_type],
                     ''.join(random.sample(DOCNUMS,
                                           TYPE2NUMBER[document_type])))


def jump_holydays(date):
    weekday = date.weekday()
    if weekday in (5, 6):
        date += timedelta(days=1 + 6 - weekday)
    return date


## CREATE DISPATCHES
def create_dispatches(agency, datastore, customers, n=5):
    from calendar import monthrange

    list_dispatches = []
    year = 2015

    dt_curr = datetime.now()
    curr_month = dt_curr.month
    dt_prev = datetime(dt_curr.year, curr_month, 1) - timedelta(days=1)
    prev_month = (dt_prev).month
    max_days = {
        curr_month: dt_curr.day - 3 if dt_curr.day > 3 else dt_curr.day,
        prev_month: monthrange(dt_prev.year, dt_prev.month)[1]
    }

    def generate_date(by_month):
        return jump_holydays(
            datetime(year,
                     by_month,
                     random.randint(1, max_days[by_month])))

    N = n

    income_dates = sorted(
        [generate_date(prev_month) for i in range(N - N/5)] +
        [generate_date(curr_month) for i in range(N/5)], reverse=True)

    customers_all = customers
    customer_flag = True
    customers = random.sample(customers, int(len(customers) * .25))

    while n:
        if customer_flag and n < (N/4):
            customer_flag = False
            customers = customers_all

        customer = random.choice(customers)
        jurisdiction = random.choice(jurisdictions)
        regime = random.choice(regimes)

        income_date = income_dates[n - 1]

        dispatch = Dispatch(order='%s-%03d' % (year, N - n + 1),
                            customer_key=customer.key,
                            customs_agency_key=agency.key,
                            jurisdiction=jurisdiction,
                            regime=regime,
                            stakeholders=[random.choice(stakeholders)],
                            income_date=income_date,
                            reference=''.join(
                                random.choice(digits) for _ in range(10)),
                            description=('Descripción de la mercancía'
                                         ' del despacho'))
        dispatch.declaration = Dispatch.Declaration(customer=customer)

        dispatch.stakeholders[0].link_type = ('Destinatario de embarque'
                                              if dispatch.is_out
                                              else 'Proveedor')
        dispatch.declaration.customer.link_type = ('Exportador'
                                                   if dispatch.is_out
                                                   else 'Importador')
        dispatch.store()
        datastore.pending_key.append(dispatch.key)
        datastore.store()
        list_dispatches.append(dispatch.key)
        n -= 1

    return [d for d in list_dispatches
            if d.get().customs_agency_key == agency.key]

## NUMERATE DISPATCHES
def numerate_dispatches(agency, percent):
    year = 2015
    dispatches = Dispatch.all(customs_agency_key=agency.key)
    dispatches_n = random.sample(dispatches,
                                 int(len(dispatches)*percent))
    for dispatch in dispatches_n:
        jurisdiction = dispatch.jurisdiction
        regime = dispatch.regime
        income_date = dispatch.income_date
        dispatch.numeration_date=jump_holydays(
                                    income_date + timedelta(days=2))
        dispatch.exchange_rate=random.choice(('3.51','3.52','3.53','3.54'))
        dispatch.dam = '%s-%s-%s-%s' % (jurisdiction.code,
                                        year, regime.code,
                                        ''.join(random.sample(digits, 6)))
        dispatch.channel = random.choice(('V', 'N', 'R'))
        dispatch.amount = float(random.paretovariate(4.5) * 7200.75)
        dispatch.store()

    return dispatches_n

## DELETE DISPATCHES
def drop_dispatches(agency):
    dispatches = Dispatch.all(customs_agency_key=agency.key)
    datastore = agency.datastore
    for dispatch in dispatches:
        datastore.pending_key.remove(dispatch.key)
        datastore.store()
        dispatch.delete()
    agency.store()

## CREATE OPERATIONS
def create_operation(agency, dstp_operation):
    datastore = agency.datastore
    counter = datastore.next_operation_counter()
    operation = Operation(customs_agency_key=agency.key,
                          counter=counter)
    operation.store()

    for dispatch_key in list(dstp_operation):
        operation.dispatches_key.append(dispatch_key)

        dispatch = dispatch_key.get()

        operation.customer_key = dispatch.customer_key
        dispatch.operation_key = operation.key
        dispatch.store()
    operation.store()
    datastore.operations_key.append(operation.key)
    datastore.store()


def operations(agency):
    dispatches = Dispatch.all(customs_agency_key=agency.key)
    dispatch_set = set([d.key for d in dispatches])

    while dispatch_set:
        dispatch = random.choice(list(dispatch_set))

        dstp_operation = set([dispatch])
        # NO CONSIDERO LAS MULTIPLE PARA PODER VER SU
        # FUNCIÓN POR SEPARADO.
        # SOLO CONSIDERO LOS SIMPLES.
        if dispatch.get().amount >= 10000:
            create_operation(agency, dstp_operation)
        else:
            dispatches_o = [d for d in list(dispatch_set)
                            if d.get().customer_key == dispatch.get().customer_key]
            amount = sum(d.get().amount for d in dispatches_o)

            if amount >= 50000:
                dstp_operation = set(dispatches_o)
                create_operation(agency, dstp_operation)

        dispatch_set = dispatch_set.difference(dstp_operation)


## READ ALERTS
def read_alerts():
    operation_secod = (('I', '3'), ('I', '5'), ('I', '7'),
                       ('I', '8'), ('I', '10'), ('I', '11'),
                       ('I', '12'), ('I', '13'), ('I', '14'),
                       ('I', '15'), ('I', '16'), ('I', '17'),
                       ('I', '18'), ('III', '1'), ('III', '2'),
                       ('III', '3'), ('III', '4'), ('III', '5'),
                       ('III', '6'), ('III', '7'), ('III', '8'),
                       ('III', '9'), ('III', '10'), ('III', '11'),
                       ('III', '12'), ('III', '13'), ('III', '14'),
                       ('III', '15'), ('III', '16'), ('III', '17'),
                       ('III', '18'), ('III', '19'), ('III', '20'),
                       ('III', '21'), ('III', '22'), ('III', '23'),
                       ('III', '24'), ('III', '25'), ('III', '26'),
                       ('III', '27'), ('III', '28'), ('III', '29'),
                       ('III', '30'), ('III', '31'), ('III', '32'),
                       ('III', '33'))

    finance_secod = (('I', '4'),
                     ('I', '6'),
                     ('I', '9'),
                     ('I', '11'),
                     ('I', '13'),
                     ('I', '15'),
                     ('I', '17'),
                     ('I', '18'))

    comercial_secod = (('I', '1'),
                       ('I', '2'),
                       ('I', '9'),
                       ('I', '10'),
                       ('I', '11'),
                       ('I', '14'),
                       ('I', '16'))

    alert_comercial_keys = []
    alert_finance_keys = []
    alert_operation_keys = []

    for alert in Alert.all():

        tuple_alert = (alert.section, alert.code)
        if tuple_alert in operation_secod:
            alert_operation_keys.append(alert.key)
        if tuple_alert in finance_secod:
            alert_finance_keys.append(alert.key)
        if tuple_alert in comercial_secod:
            alert_comercial_keys.append(alert.key)

    roles = User.role_choices
    alerts_keys = [alert_comercial_keys,
                   alert_finance_keys,
                   alert_operation_keys]

    return dict(zip(roles, alerts_keys))

## CREATE EMPLOYEES
def create_employees(agency, j=3):

    modules = data_generator.permissions.employee

    dict_alerts = read_alerts()

    roles = User.role_choices

    data = (('cristhian@cavasoftsac.com', 'Cristhian Gonzales'),
            ('henry@cavasoftsac.com', 'Henry Vargas'),
            ('javier@cavasoftsac.com', 'Javier Huaman'))

    while j:
        role = roles[j%3]
        permission = Permissions(modules=modules,
                                 alerts_key=dict_alerts[role])
        permission.store()
        employee = Employee(name=data[j % 3][1],
                            username=data[j % 3][0],
                            password='123',
                            customs_agency_key=agency.key,
                            permissions_key=permission.key,
                            role=role)
        employee.store()
        agency.employees_key.append(employee.key)
        j -= 1
    agency.store()

## CREATE OPERATION UNUSUAL -- VERIFICAR
def create_unusual(agency, percent):
    dispatches = [d.key for d in agency.datastore.pending]
    for k in random.sample(dispatches,
                           int(len(dispatches)*percent)):
        dispatch = k.get()
        employee = random.choice(agency.employees)
        role2keys = read_alerts()
        info_keys = random.sample(role2keys[employee.role],
                                  random.randint(1, 5))
        dispatch.alerts = [
            Dispatch.Alert(info_key=info_key,
                           comment='Comentario de la alerta.',
                           source='Otras Fuentes',
                           description_source='Descripción de la fuente.')
            for info_key in info_keys]
        dispatch.description_unusual = ('Descripción de la '
                                        'operación inusual.')
        is_suspects = random.choice((True, False))
        if is_suspects:
            dispatch.ros = ''.join(random.sample(DOCNUMS, 6))
        else:
            dispatch.suspects_by = 'No cumple las reglas.'
        dispatch.is_suspects = is_suspects
        dispatch.declaration.customer.unusual_condition = 'Involucrado'
        dispatch.stakeholders[0].unusual_condition = 'Vinculado'
        dispatch.declaration.customer.unusual_operation = 'es Involucrado'
        dispatch.stakeholders[0].unusual_operation = 'es Vinculado'
        dispatch.alerts_visited = [str(employee.key.id())]

        dispatch.store()


## #############################
## NO-DEPENDENCY [TABLES]
## #############################

## CREATE CUSTOMERS
def create_customers():
    from collections import namedtuple

    DCustomer = namedtuple('DCustomer', 'name document_type')

    init_customers = [
        DCustomer('ARTESCO S.A',
                  'ruc'),
        DCustomer('BLUE DIAMOND GROUP S.A.C.',
                  'ruc'),
        DCustomer('CANA DYNE EQUIPMENT AND SERVICES S.A.',
                  'ruc'),
        DCustomer('COTTON PROYECT S.A.C.',
                  'ruc'),
        DCustomer('Abanto Alvarado Corpos A.',
                  'dni'),
        DCustomer('DETROIT DIESEL - MTU PERU S.A.C',
                  'ruc'),
        DCustomer('HIELOSNORTE S.A.C.',
                  'ruc'),
        DCustomer('INDUSTRIAS DEL SHANUSI S.A.',
                  'ruc'),
        DCustomer('Lima Caucho S.A.',
                  'ruc'),
        DCustomer('NESTLE MARCAS PERU S.A.C.',
                  'ruc'),
        DCustomer('PERUANA S.A.C.',
                  'ruc'),
        DCustomer('ROMOVI S.A.C.',
                  'ruc'),
        DCustomer('SAMSUNG ELECTRONICS PERU S.A.C.',
                  'ruc'),
        DCustomer('SOUTHERN PERU COPPER CORPORATION SUCURSAL DEL PERU',
                  'ruc'),
    ]

    customer_by = {
        'ruc': Business,
        'dni': Person
    }

    shareholders = [
        Customer.Shareholder(name='Avalos Polo, Cesar Erick',
                             document_number='06109617',
                             document_type='dni',
                             ratio='8'),
        Customer.Shareholder(name='Salhuana Paredes, Carlos Eduardo',
                             document_number='08222566',
                             document_type='dni',
                             ratio='15'),
        Customer.Shareholder(name='Salhuana Benza, Carlos Oswaldo',
                             document_number='08239074',
                             document_type='dni',
                             ratio='15'),
        Customer.Shareholder(name='Monzon Paredes, Luis William',
                             document_number='08798935',
                             document_type='dni',
                             ratio='17'),
    ]

    customers = []
    for data in init_customers:
        document_number = pick_document_number_by(data.document_type)

        customer = customer_by[data.document_type](
            name=data.name,
            document_type=data.document_type,
            document_number=document_number,
            social_object='Comercial',
            activity='Ventas partes, piezas, accesorios',
            shareholders=shareholders,
            legal=Customer.Legal(name='Salhuana Paredes, Carlos Eduardo'),
            address='Av. Jose Chipocco 125 Barranco',
            fiscal_address=('Av. Argentina 2020  ZI Zona'
                            ' Industrial Lima Lima Lima'),
            phone='511 448-3691',
            money_source_type='No efectivo',
            money_source='Recursos de la empresa',
            is_obligated=False,
            has_officer=False,
            declarants=[random.choice(declarants)],
            condition='Residente',
            represents_to='Mandatario',
            ciiu=CodeName(code='18100',
                          name=('FAB. DE PRENDAS'
                                ' DE VESTIR.')),
            ubigeo=CodeName(code='150115',
                            name=('LIMA - LIMA -'
                                  ' LA VICTORIA')))
        customer.store()
        customers.append(customer)

    return customers

## CREATE AGENCY
def create_agency():
    import uuid
    agency = (str(uuid.uuid1()))[:8]

    ca = CustomsAgency(name='Agencia - %s' % agency)
    ca.store()

    alert_signals_key = [alert.key for alert in Alert.all()]

    ds = Datastore(customs_agency_key=ca.key,
                   alerts_key=alert_signals_key)
    ds.store()

    perms = Permissions(modules=data_generator.permissions.officer)
    perms.store()

    of = Officer(customs_agency_key=ca.key,
                 name='Oficial de Cumplimiento',
                 username='%s@cavasoftsac.com' % agency,
                 password=agency,
                 permissions_key=perms.key)
    ca.officer_key = of.store()
    ca.store()

    return ca


## CREATE STAKEHOLDERS
def create_stakeholders():
    for stakeholder in stakeholders:
        stakeholder.document_number = pick_document_number_by(
            stakeholder.document_type)
        stakeholder.store()
    return stakeholders


## CREATE ALERTS
def create_alerts():
    """Main alerts."""
    for section, code, description, help in data_generator.alerts.alerts:
        alert = Alert(section=section, code=code,
                      description=description)
        alert.store()

## CREATE WORKERS
def create_workers():
    from datetime import datetime, timedelta
    data = (
        ('Persona 1', '123456'),
        ('Persona 2', '345666'),
        ('Persona 3', '576886'),
        ('Persona 4', '890890'),
    )
    for name, document_number in data:
        worker = Worker(name=name,
                        document_number=document_number)
        worker_key = worker.store()

        for i in range(random.randint(4, 7)):
            knowledge = KnowledgeWorker(worker_key=worker_key)
            knowledge.created = (datetime.now()
                                 + random.choice((-1, 1))
                                 * timedelta(hours=random.randint(40, 90)))
            knowledge.store()


# vim: et:ts=4:sw=4
