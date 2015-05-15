# encoding: utf-8
"""
.. module:: plaft.application.util
   :synopsis: Provides sample data.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from __future__ import unicode_literals
import random
from plaft.domain.model import (User, Dispatch, CodeName, Declaration,
                                Customer, Third, Declarant, Stakeholder,
                                Business, Datastore, CustomsAgency,
                                Operation, Officer, Employee)


# Utils

TYPE2NUMBER = {
    'ruc': 11,
    'dni': 8
}

DOCNUMS = ('0', '1', '2', '3', '4',
           '5', '6', '7', '8', '9',
           '0', '1', '2', '3', '4',
           '5', '6', '7', '8', '9')

def pick_document_number_by(document_type):
    return ''.join(random.sample(DOCNUMS, TYPE2NUMBER[document_type]))


# Creations

def create_stakeholders():
    for stakeholder in stakeholders:
        stakeholder.document_number = pick_document_number_by(
            stakeholder.document_type)

        stakeholder.store()


def create_autocomplete():
    from collections import namedtuple

    DStakeholder = namedtuple('DStakeholder',
                              'name document_type')

    init_customers = [
        DStakeholder('Sony',
                     'ruc'),
        DStakeholder('Coca Cola',
                     'ruc'),
        DStakeholder('Microsoft',
                     'ruc'),
        DStakeholder('Javier Huaman',
                     'dni'),
        DStakeholder('Cristhian Gonzales',
                     'dni'),
        DStakeholder('Antonio Adama',
                     'dni'),
    ]

    # type2customer = {
    #     'ruc': 'Jurídica',
    #     'dni': 'Natural'
    # }

    for data in init_customers:
        document_number = pick_document_number_by(data.document_type)

        stakeholder = Stakeholder(name=data.name,
                                  document_type=data.document_type,
                                  document_number=document_number)
        stakeholder.store()


def create_employees(agency, j=7):
    from string import ascii_lowercase

    j = random.randint(2, j)
    while j:
        username = ''.join(random.sample(ascii_lowercase, 3))
        employee = Employee(username=username, password='123')
        employee.store()
        agency.employees_key.append(employee.key)
        j -= 1
    agency.store()


def create_dispatches(agency, datastore, customers, n=20):
    from string import digits, letters

    years = ['2014', '2015', '2016']
    list_dispatches = []

    while n:
        order = '%s-%s' % (random.choice(years),
                           ''.join(random.sample(digits, 5)))
        customer = random.choice(customers)
        declaration = Declaration(customer=customer)
        declaration.store()
        jurisdiction = random.choice(jurisdictions)
        regime = random.choice(regimes)
        dispatch = Dispatch(order=order,
                            customer_key=customer.key,
                            declaration_key=declaration.key,
                            customs_agency_key=agency.key,
                            jurisdiction=jurisdiction,
                            regime=regime,
                            sender_stakeholders=[
                                random.choice(stakeholders)],
                            reciever_stakeholders=[
                                random.choice(stakeholders)])
        dispatch.store()
        datastore.pending_key.append(dispatch.key)
        datastore.store()
        list_dispatches.append(dispatch.key)
        n -= 1

    return [d for d in list_dispatches
            if d.get().customs_agency_key == agency.key]


def create_operation(agency, dstp_operation, datastore):
    operation = Operation(customs_agency_key=agency.key)
    operation.store()

    for dispatch_key in list(dstp_operation):
        operation.dispatches_key.append(dispatch_key)

        dispatch = dispatch_key.get()

        operation.customer_key = dispatch.customer_key
        datastore.accepting_key.append(dispatch_key)
        dispatch.operation_key = operation.key
        dispatch.store()
    operation.store()
    datastore.pending_key = list(
        set(datastore.pending_key).difference(dstp_operation))
    datastore.store()


def operations(agency, list_dispatches, datastore):
    dispatch_set = set(random.sample(list_dispatches,
                                     int(len(list_dispatches)*0.75)))

    while dispatch_set:
        dispatch = random.choice(list(dispatch_set))
        is_multiple = random.choice([True, False])

        dstp_operation = set([dispatch])
        if is_multiple:
            dstp_operation = set(
                [dstp
                 for dstp in list(dispatch_set)
                 if dstp.get().customer == dispatch.get().customer])

        create_operation(agency, dstp_operation, datastore)
        dispatch_set = dispatch_set.difference(dstp_operation)


def create_sample_data():
    create_stakeholders()

    from collections import namedtuple

    DCustomer = namedtuple('DCustomer',
                           'name document_type')
    init_customers = [
        DCustomer('Sony',
                  'ruc'),
        DCustomer('Coca Cola',
                  'ruc'),
        DCustomer('Microsoft',
                  'ruc'),
        DCustomer('Javier Huaman',
                  'dni'),
        DCustomer('Cristhian Gonzales',
                  'dni'),
        DCustomer('Antonio Adama',
                  'dni'),
    ]

    customers = []
    for data in init_customers:
        document_number = pick_document_number_by(data.document_type)

        customer = Customer(name=data.name,
                            document_type=data.document_type,
                            document_number=document_number)
        customer.store()
        customers.append(customer)

    Data = namedtuple('Data', 'customs_agency officer username password')

    init_data = [
        Data('Massive Dynamic',
             'Nina Sharp',
             'gcca@mail.io',
             '789'),
        Data('Cyberdine',
             'Mice Dyson',
             'mice@cd.io',
             '123'),
        Data('CavaSoft SAC',
             'César Vargas',
             'cesarvargas@cavasoftsac.com',
             '123')
    ]

    for data in init_data:
        agency = CustomsAgency(name=data.customs_agency)
        agency.store()

        create_employees(agency)

        datastore = Datastore(customs_agency_key=agency.key)
        datastore.store()

        officer = Officer(name=data.officer,
                          username=data.username,
                          password=data.password,
                          customs_agency_key=agency.key)
        officer.store()

        agency.officer_key = officer.key
        agency.store()

        list_dispatches = create_dispatches(agency, datastore, customers)
        operations(agency, list_dispatches, datastore)

    create_autocomplete()  # TODO: Remove when update domain model


# LIST

regimes = [
    CodeName(name='Importacion para el Consumo',
             code='10'),
    CodeName(name='Reimportacion en el mismo Estado',
             code='36'),
    CodeName(name='Exportacion Definitiva',
             code='40'),
    CodeName(name=('Exportacion Temporal para Reimportacion'
                   'en el mismo Estado'),
             code='51'),
    CodeName(name='Exportacion Temporal para Perfeccionamiento Pasivo',
             code='52'),
    CodeName(name='Admision temporal para Perfeccionamiento Activo',
             code='21'),
    CodeName(name='Admision temporal para Reexportacion en el mismo Estado',
             code='20'),
    CodeName(name='Drawback',
             code='41'),
    CodeName(name='Reposicion de Mercancias con Franquicia Arancelaria',
             code='41'),
    CodeName(name='Deposito Aduanero',
             code='70'),
    CodeName(name='Reembarque',
             code='89'),
    CodeName(name='Transito Aduanero',
             code='80'),
    CodeName(name='Importacion Simplificada',
             code='18'),
    CodeName(name='Exportacion Simplificada',
             code='48'),
    CodeName(name='Material de Uso Aeronautico',
             code='71'),
    CodeName(name='Destino Especial de Tienda Libre (DUTY FREE)',
             code='72'),
    CodeName(name='Rancho de naves',
             code=''),
    CodeName(name='Material de Guerra',
             code=''),
    CodeName(name='Vehiculos para Turismo',
             code=''),
    CodeName(name='Material uso Aeronautico',
             code=''),
    CodeName(name='Ferias o Exposiciones Internacionales',
             code='20')
]


raw_jurisdiction = (
    ('A NIVEL NACIONAL', '983'),
    ('AÉREA DEL CALLAO', '235'),
    ('AEROPUERTO DE TACNA', '947'),
    ('ALMACÉN SANTA ANITA', '974'),
    ('AREQUIPA', '154'),
    ('CETICOS - TACNA', '956'),
    ('CHICLAYO', '055'),
    ('CHIMBOTE', '091'),
    ('COMPLEJO FRONTERIZO SANTA ROSA - TACNA', '929'),
    ('CUSCO', '190'),
    ('DEPENDENCIA FERROVIARIA TACNA', '884'),
    ('DEPENDENCIA POSTAL DE AREQUIPA', '910'),
    ('DEPENDENCIA POSTAL DE SALAVERRY', '965'),
    ('DEPENDENCIA POSTAL TACNA', '893'),
    ('DESAGUADERO', '262'),
    ('ILO', '163'),
    ('INTENDENCIA DE PREVENCIÓN Y CONTROL FRONTERIZO', '316'),
    ('INTENDENCIA NACIONAL DE FISCALIZACIÓN ADUANERA (INFA)', '307'),
    ('IQUITOS', '226'),
    ('LA TINA', '299'),
    ('LIMA METROPOLITANA', '992'),
    ('MARÍTIMA DEL CALLAO', '118'),
    ('MOLLENDO - MATARANI', '145'),
    ('OFICINA POSTAL DE LINCE', '901'),
    ('PAITA', '046'),
    ('PISCO', '127'),
    ('POSTAL DE LIMA', '244'),
    ('PUCALLPA', '217'),
    ('PUERTO MALDONADO', '280'),
    ('PUNO', '181'),
    ('SALAVERRY', '082'),
    ('SEDE CENTRAL - CHUCUITO', '000'),
    ('TACNA', '172'),
    ('TALARA', '028'),
    ('TARAPOTO', '271'),
    ('TERMINAL TERRESTRE TACNA', '928'),
    ('TUMBES', '019'),
    ('VUCE ADUANAS', '848')
)

jurisdictions = tuple(CodeName(name=j[0], code=j[1])
                      for j in raw_jurisdiction)


raw_stakeholders = (
    # (document_type, name, address)
    ('ruc', 'LexCorp', 'DC Comics'),
    ('ruc', 'Primatech', 'Heroes'),
    ('ruc', 'Blue Sun', 'Firefly and Serenity'),
    ('ruc', 'Merrick Biotech', 'The Island'),
    ('ruc', 'Fatboy Industries', 'The Middleman'),
    ('ruc', 'Buy n Large Corporation', 'WALL•E'),
    ('ruc', 'Tyrell Corporation', 'Blade Runner'),
    ('ruc', 'Veidt Industries', 'Watchmen'),
    ('ruc', 'Weyland-Yutani', 'Alien franchise'),
    ('ruc', 'Cyberdyne Systems Corporation', 'Terminator'),
    ('ruc', 'Yoyodyne', 'The Crying of Lot 49 and V. by Thomas Pynchon'),
    ('ruc', 'Earth Protectors', 'Up, Up, and Away, 2000'),
    ('ruc', 'Omni Consumer Products', 'Robocop'),
    ('ruc', 'Soylent Corporation', 'Soylent Green'),
    ('ruc', 'GeneCo', 'Repo! The Genetic Opera'),
    # block 2
    ('ruc', 'CHOAM', 'Dune'),
    ('ruc', 'Acme Corp.', 'Looney Tunes'),
    ('ruc', 'Sirius Cybernetics Corp.', 'Hitchhiker’s Guide'),
    ('ruc', 'MomCorp', 'Futurama'),
    ('ruc', 'Rich Industries', 'Richie Rich'),
    ('ruc', 'Soylent Corp.', 'Soylent Green'),
    ('ruc', 'Very Big Corp. of America', 'Monty Python'),
    ('ruc', 'Frobozz Magic Co.', 'Zork'),
    ('ruc', 'Warbucks Industries', 'Lil’ Orphan Annie'),
    ('ruc', 'Tyrell Corp.', 'Bladerunner'),
    ('ruc', 'Wayne Enterprises', 'Batman'),
    ('ruc', 'Virtucon', 'Austin Powers'),
    ('ruc', 'Globex', 'The Simpsons'),
    ('ruc', 'Umbrella Corp.', 'Resident Evil'),
    ('ruc', 'Wonka Industries', 'Charlie... Choc. Factory'),
    ('ruc', 'Stark Industries', 'Iron Man'),
    ('ruc', 'Clampett Oil', 'Beverly Hillbillies'),
    ('ruc', 'Oceanic Airlines', 'Lost'),
    ('ruc', 'Yoyodyne Propulsion Sys.', 'Crying of Lot 49'),
    ('ruc', 'Cyberdyne Systems Corp.', 'Terminator'),
    ('ruc', 'd’Anconia Copper', 'Atlas Shrugged'),
    ('ruc', 'Gringotts', 'Harry Potter'),
    ('ruc', 'Oscorp', 'Spider-Man'),
    ('ruc', 'Nakatomi Trading Corp.', 'Die-Hard'),
    ('ruc', 'Spacely Space Sprockets', 'The Jetsons')
)

stakeholders = tuple(Stakeholder(document_type=j[0],
                                 name=j[1],
                                 address=j[2])
                     for j in raw_stakeholders)

# vim: et:ts=4:sw=4
