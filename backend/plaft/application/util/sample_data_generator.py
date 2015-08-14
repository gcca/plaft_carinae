# encoding: utf-8
"""
.. module:: plaft.application.util
   :synopsis: Provides sample data.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <gcca@gcca.tk>


"""

from __future__ import unicode_literals
import random
import plaft.config
from plaft.domain.model import (Dispatch, CodeName, Declarant, Stakeholder,
                                Business, Person, Datastore, CustomsAgency,
                                Operation, Officer, Employee, Permissions,
                                Alert, User, Customer)
from plaft.application.util import data_generator


# Utils

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

    return '%s%s' %(TYPE[document_type],
                   ''.join(random.sample(DOCNUMS, TYPE2NUMBER[document_type])))


# Creations

def create_stakeholders():
    for stakeholder in stakeholders:
        stakeholder.document_number = pick_document_number_by(
            stakeholder.document_type)

        stakeholder.store()


def create_declarants():
    for declarant in declarants:
        declarant.document_type = 'dni'
        declarant.document_number = pick_document_number_by('dni')

        declarant.store()


def create_alerts():
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

    for alert in Alert.query().fetch():
        alert_signals_key.append(alert.key)

        tuple_alert = (alert.section, alert.code)
        if tuple_alert in operation_secod:
            alert_operation_keys.append(alert.key)
        if tuple_alert in finance_secod:
            alert_finance_keys.append(alert.key)
        if tuple_alert in comercial_secod:
            alert_comercial_keys.append(alert.key)


def create_employees(agency, j=3):
    from string import ascii_lowercase

    modules = data_generator.permissions.employee

    alerts_keys = [alert_comercial_keys,
                   alert_finance_keys,
                   alert_operation_keys]
    roles = User.role_choices

    data = (('cristhian@cavasoftsac.com', 'Cristhian Gonzales'),
            ('henry@cavasoftsac.com', 'Henry Vargas'),
            ('javier@cavasoftsac.com', 'Javier Huaman'))

    while j:
        permission = Permissions(modules=modules,
                                 alerts_key=alerts_keys[j % 3])
        permission.store()
        employee = Employee(name=data[j % 3][0],
                            username=data[j % 3][1],
                            password='123',
                            customs_agency_key=agency.key,
                            permissions_key=permission.key,
                            role=roles[j % 3])
        employee.store()
        agency.employees_key.append(employee.key)
        j -= 1
    agency.store()


def create_dispatches(agency, datastore, customers, n=30):
    from string import digits
    from datetime import datetime, timedelta
    from calendar import monthrange

    list_dispatches = []
    year = 2015

    dt_curr = datetime.now()
    curr_month = dt_curr.month
    dt_prev = datetime(dt_curr.year, curr_month, 1) - timedelta(days=1)
    prev_month = (dt_prev).month
    max_days = {
        curr_month: monthrange(dt_curr.year, dt_curr.month)[1],
        prev_month: dt_curr.day
    }
    months = (prev_month, curr_month)

    while n:
        customer = random.choice(customers)
        jurisdiction = random.choice(jurisdictions)
        regime = random.choice(regimes)
        dam = '%s-%s-%s-%s' % (jurisdiction.code,
                               year, regime.code,
                               ''.join(random.sample(digits, 6)))
        choice_month = random.choice(months)
        income_date = datetime(year, choice_month,
                               random.randint(1,max_days[choice_month]))
        numeration_date = income_date + timedelta(days=2)
        dispatch = Dispatch(order='%s-%03d' % (year, n),
                            customer_key=customer.key,
                            customs_agency_key=agency.key,
                            jurisdiction=jurisdiction,
                            regime=regime,
                            stakeholders=[random.choice(stakeholders)],
                            amount=str(random.randint(3999, 11111)),
                            income_date=income_date,
                            dam=dam,
                            numeration_date=numeration_date,
                            channel=random.choice(('V', 'N', 'R')),
                            exchange_rate=random.choice(('3.51',
                                                         '3.52',
                                                         '3.53',
                                                         '3.54')),
                            reference=''.join(
                                random.choice(digits) for _ in range(10)),
                            description='Descripción del mercancía del despacho')
        dispatch.declaration = Dispatch.Declaration(customer=customer)

        if random.choice((True, False)):
            employee = random.choice(agency.employees)
            role2keys = {
                'Comercial': alert_comercial_keys,
                'Operación': alert_operation_keys,
                'Finanza': alert_finance_keys
            }

            info_keys = random.sample(role2keys[employee.role],
                                      random.randint(1, 5))
            dispatch.alerts = [
                Dispatch.Alert(info_key=info_key,
                               comment='Comentario de la alerta.',
                               source='Alguna fuente.',
                               description_source='Descripción de la fuente.')
                               for info_key in info_keys]
            dispatch.alerts_visited = [str(employee.key.id())]

        dispatch.store()
        dispatch.stakeholders[0].link_type =  'Destinatario de embarque' \
                                                if dispatch.is_out \
                                                else 'Proveedor'
        dispatch.store()
        datastore.pending_key.append(dispatch.key)
        datastore.store()
        list_dispatches.append(dispatch.key)
        n -= 1

    return [d for d in list_dispatches
            if d.get().customs_agency_key == agency.key]


def create_operation(agency, dstp_operation, datastore):
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


def operations(agency, list_dispatches, datastore):
    dispatch_set = set(list_dispatches)

    while dispatch_set:
        dispatch = random.choice(list(dispatch_set))

        dstp_operation = set([dispatch])
        # NO CONSIDERO LAS MULTIPLE PARA PODER VER SU
        # FUNCIÓN POR SEPARADO.
        # SOLO CONSIDERO LOS SIMPLES.
        if float(dispatch.get().amount) >= 10000:
            create_operation(agency, dstp_operation, datastore)
        dispatch_set = dispatch_set.difference(dstp_operation)


def _data_debug():
    create_stakeholders()
    create_declarants()
    create_alerts()

    from collections import namedtuple
    from string import digits

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
        # DCustomer('Javier Huaman',
        #           'dni'),
        # DCustomer('Cristhian Gonzales',
        #           'dni'),
        # DCustomer('María Cayetana',
        #           'dni'),
        # DCustomer('Antonio Adama',
        #           'dni'),
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
            legal='Salhuana Paredes, Carlos Eduardo',
            address='Av. Jose Chipocco 125 Barranco',
            fiscal_address=('Av. Argentina 2020  ZI Zona'
                            ' Industrial Lima Lima Lima'),
            phone='511 448-3691',
            money_source_type='No efectivo',
            money_source='Recursos de la empresa',
            is_obligated=False,
            has_officer=False,
            declarants=[random.choice(declarants)])
        customer.store()
        customers.append(customer)

    Data = namedtuple('Data',
                      'customs_agency officer username password modules')

    init_data = [
        # Data('Massive Dynamic',
        #      'Nina Sharp',
        #      'nina@mass.dyn',
        #      '789',
        #      data_generator.permissions.officer),
        Data('CavaSoft SAC',
             'César Vargas',
             'cesarvargas@cavasoftsac.com',
             '123',
             data_generator.permissions.officer)
    ]

    for data in init_data:
        agency = CustomsAgency(name=data.customs_agency)
        agency.store()

        create_employees(agency)

        datastore = Datastore(customs_agency_key=agency.key,
                              alerts_key=alert_signals_key)
        datastore.store()

        permission = Permissions(modules=data.modules,
                                 alerts_key=alert_signals_key)
        permission.store()

        officer = Officer(name=data.officer,
                          username=data.username,
                          password=data.password,
                          customs_agency_key=agency.key,
                          permissions_key=permission.key,
                          role='Operación')
        officer.store()

        agency.officer_key = officer.key
        agency.store()

        list_dispatches = create_dispatches(agency, datastore, customers)
        operations(agency, list_dispatches, datastore)

    # HARDCODED data
    # _data_deploy()


def _data_deploy():
    if CustomsAgency.find(name='CavaSoft SAC'):
        return

    ca = CustomsAgency(name='CavaSoft SAC')
    ca.store()

    ds = Datastore(customs_agency_key=ca.key,
                   alerts_key=alert_signals_key)
    ds.store()

    perms = Permissions(modules=data_generator.permissions.officer)
    perms.store()

    of = Officer(customs_agency_key=ca.key,
                 name='César Vargas',
                 username='cesarvargas@cavasoftsac.com',
                 password='123',
                 permissions_key=perms.key)
    ca.officer_key = of.store()
    ca.store()


# _create_sample_data = _data_debug if plaft.config.DEBUG else _data_deploy
_create_sample_data = _data_debug


def create_sample_data():
    from plaft.application.util.data_generator import init
    init()
    _create_sample_data()


# LIST

raw_regimes = (
    ('Importacion para el Consumo', '10'),
    # ('Reimportacion en el mismo Estado', '36'),
    # ('Exportacion Definitiva', '40'),
    # ('Exportacion Temporal para Reimportacion en el mismo Estado', '51'),
    # ('Exportacion Temporal para Perfeccionamiento Pasivo', '52'),
    # ('Admision temporal para Perfeccionamiento Activo', '21'),
    # ('Admision temporal para Reexportacion en el mismo Estado', '20'),
    ('Drawback', '41'),
    # ('Reposicion de Mercancias con Franquicia Arancelaria', '41'),
    # ('Deposito Aduanero', '70'),
    # ('Reembarque', '89'),
    # ('Transito Aduanero', '80'),
    # ('Importacion Simplificada', '18'),
    # ('Exportacion Simplificada', '48'),
    # ('Material de Uso Aeronautico', '71'),
    # ('Destino Especial de Tienda Libre (DUTY FREE)', '72'),
    # ('Rancho de naves', '99'),
    # ('Material de Guerra', '99'),
    # ('Vehiculos para Turismo', '99'),
    # ('Material uso Aeronautico', '99'),
    # ('Ferias o Exposiciones Internacionales', '20')
)

regimes = tuple(CodeName(name=j[0], code=j[1]) for j in raw_regimes)


raw_jurisdiction = (
    # ('A NIVEL NACIONAL', '983'),
    ('AÉREA DEL CALLAO', '235'),
    # ('AEROPUERTO DE TACNA', '947'),
    # ('ALMACÉN SANTA ANITA', '974'),
    # ('AREQUIPA', '154'),
    # ('CETICOS - TACNA', '956'),
    # ('CHICLAYO', '055'),
    # ('CHIMBOTE', '091'),
    # ('COMPLEJO FRONTERIZO SANTA ROSA - TACNA', '929'),
    # ('CUSCO', '190'),
    # ('DEPENDENCIA FERROVIARIA TACNA', '884'),
    # ('DEPENDENCIA POSTAL DE AREQUIPA', '910'),
    # ('DEPENDENCIA POSTAL DE SALAVERRY', '965'),
    # ('DEPENDENCIA POSTAL TACNA', '893'),
    # ('DESAGUADERO', '262'),
    # ('ILO', '163'),
    # ('INTENDENCIA DE PREVENCIÓN Y CONTROL FRONTERIZO', '316'),
    # ('INTENDENCIA NACIONAL DE FISCALIZACIÓN ADUANERA (INFA)', '307'),
    # ('IQUITOS', '226'),
    # ('LA TINA', '299'),
    # ('LIMA METROPOLITANA', '992'),
    ('MARÍTIMA DEL CALLAO', '118'),
    # ('MOLLENDO - MATARANI', '145'),
    # ('OFICINA POSTAL DE LINCE', '901'),
    # ('PAITA', '046'),
    # ('PISCO', '127'),
    # ('POSTAL DE LIMA', '244'),
    # ('PUCALLPA', '217'),
    # ('PUERTO MALDONADO', '280'),
    # ('PUNO', '181'),
    # ('SALAVERRY', '082'),
    # ('SEDE CENTRAL - CHUCUITO', '000'),
    # ('TACNA', '172'),
    # ('TALARA', '028'),
    # ('TARAPOTO', '271'),
    # ('TERMINAL TERRESTRE TACNA', '928'),
    # ('TUMBES', '019'),
    # ('VUCE ADUANAS', '848')
)

jurisdictions = tuple(CodeName(name=j[0], code=j[1])
                      for j in raw_jurisdiction)


raw_stakeholders = (
    # (document_type, name, address)
    ('ruc', 'Breaker Tecnology, Ltd.', 'direccion'),
    ('ruc', 'Empresa Pinto S.A.', 'direccion'),
    ('ruc', 'Ford Motor Corporation Inc', 'direccion'),
    ('ruc', 'Guangdong Textiles Imp.and Exp.Co.LTD', 'direccion'),
    ('ruc', 'INTAI SPA', 'direccion'),
    ('ruc', 'Idustria AVM S.A.', 'direccion'),
    ('ruc', 'MIQ Global LLC DBA MIQ Logistics', 'direccion'),
    ('ruc', 'Nestle Chile S.A.', 'direccion'),
    ('ruc', 'Prov Blue Diamont', 'direccion'),
    ('ruc', 'Prov Diesel', 'direccion'),
    ('ruc', 'Prov Hielos', 'direccion'),
    ('ruc', 'Prov Romovic', 'direccion'),
    ('ruc', 'Rubbermix S.A.S.', 'direccion'),
    ('ruc', 'Samsung Electronics CO., LTD', 'direccion'),
    ('ruc', 'Shu Far Enterprise Co. Ltd.', 'direccion')
)

stakeholders = tuple(Stakeholder(document_type=j[0],
                                 name=j[1],
                                 address=j[2],
                                 social_object='Fabricante',
                                 activity='Mayorista',
                                 # address='Por averiguar',
                                 phone='025 4566-56',
                                 country='Brasil')
                     for j in raw_stakeholders)


raw_declarants = (
    # (name, father_name, mother_name, address)
    ('Jesus', 'Peralta', 'Wiese', 'direccion'),
    ('Mariela', 'Trujillo', 'Suarez', 'direccion'),
    ('Jose Luis', 'Abanto', 'Somocursio', 'direccion'),
    ('Alfredo', 'Nakamura', 'Diaz', 'direccion'),
    ('Mariela', 'Mendoza', 'Lizandro', 'direccion'),
    ('Juana', 'Del Solar', 'Arrospide', 'direccion'),
    ('Nancy', 'Gamboa', 'Abelardo', 'direccion'),
    ('Luisa', 'Matias', 'Sarda', 'direccion'),
    ('Rosalia', 'Montenegro', 'Vinatea', 'direccion'),
    ('Henry', 'Mejia', 'Flor', 'direccion')
)

declarants = tuple(Declarant(name=j[0],
                             father_name=j[1],
                             mother_name=j[2],
                             # address=j[3],
                             represents_to='Ordenante',
                             residence_status='Residente',
                             document_type='dni',
                             document_number='09774462',
                             issuance_country='Perú',
                             # father_name='Suarez',
                             # mother_name='Perez',
                             # name='Luisa',
                             nationality='Peruana',
                             activity=('SECRETARIA, RECEPCIONISTA,'
                                       ' TELEFONISTA'),
                             ciiu=CodeName(code='18100',
                                           name=('FAB. DE PRENDAS'
                                                 ' DE VESTIR.')),
                             address='Av. Las Amapolas 569 Chacarilla',
                             ubigeo=CodeName(code='150115',
                                             name=('LIMA - LIMA -'
                                                   ' LA VICTORIA')),
                             phone='511 336-5812 Anexo 80',
                             position='Gerente de operaciones')
                   for j in raw_declarants)


alert_signals_key = []
alert_comercial_keys = []
alert_operation_keys = []
alert_finance_keys = []


# vim: et:ts=4:sw=4
