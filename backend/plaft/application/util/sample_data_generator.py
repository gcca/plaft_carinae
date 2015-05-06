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


def create_autocomplate():
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

    type2number = {
        'ruc': 11,
        'dni': 8
    }

    type2customer = {
        'ruc': 'Jurídica',
        'dni': 'Natural'
    }

    for data in init_customers:
        document_number = ''.join(
            random.sample(['0', '1', '2', '3', '4',
                           '5', '6', '7', '8', '9',
                           '0', '1', '2', '3', '4',
                           '5', '6', '7', '8', '9'],
                          type2number[data.document_type]))

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


def create_dispatches(agency, datastore, customers, n=15):
    from string import digits, letters

    years = ['2014', '2015', '2016']
    j = 5
    list_dispatches = []
    init_codename = []
    while j:
        codename = CodeName(code=''.join(random.sample(digits, 3)),
                            name=''.join(random.sample(letters, 7)))
        init_codename.append(codename)
        j -= 1

    while n:
        order = '%s-%s' % (random.choice(years),
                           ''.join(random.sample(digits, 5)))
        customer = random.choice(customers)
        declaration = Declaration(customer=customer)
        declaration.store()
        jurisdiction = random.choice(init_codename)
        regime = random.choice(init_codename)
        dispatch = Dispatch(order=order,
                            customer_key=customer.key,
                            declaration_key=declaration.key,
                            customs_agency_key=agency.key,
                            jurisdiction=jurisdiction,
                            regime=regime)
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

    type2number = {
        'ruc': 11,
        'dni': 8
    }

    customers = []
    for data in init_customers:
        document_number = ''.join(
            random.sample(['0', '1', '2', '3', '4',
                           '5', '6', '7', '8', '9',
                           '0', '1', '2', '3', '4',
                           '5', '6', '7', '8', '9'],
                          type2number[data.document_type]))
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

    create_autocomplate()


# vim: et:ts=4:sw=4
