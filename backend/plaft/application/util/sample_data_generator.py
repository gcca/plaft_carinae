# encoding: utf-8
"""
.. module:: plaft.application.util
   :synopsis: Provides sample data.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from __future__ import unicode_literals
from plaft.domain.model import (User, Dispatch, CodeName, Declaration,
                                Customer, Third, Declarant, Linked,
                                Business, Datastore, CustomsAgency,
                                Operation, Officer)
import random



def create_dispatches(agency, datastore, customers, n=25):
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
                            customer=customer.key,
                            declaration=declaration.key,
                            customs_agency=agency.key,
                            jurisdiction=jurisdiction,
                            regime=regime)
        dispatch.store()
        datastore.pending.append(dispatch.key)
        datastore.store()
        list_dispatches.append(dispatch.key)
        n -= 1

    return [d for d in list_dispatches
            if d.get().customs_agency == agency.key]


def create_operation(agency, dstp_operation, datastore):
    operation = Operation(customs_agency=agency.key)
    operation.store()

    for dispatch_key in list(dstp_operation):
        operation.dispatches.append(dispatch_key)

        dispatch = dispatch_key.get()

        operation.customer = dispatch.customer
        datastore.accepting.append(dispatch_key)
        dispatch.operation = operation.key
        dispatch.store()

    operation.store()
    datastore.pending = list(set(datastore.pending).difference(dstp_operation))
    datastore.store()

def operations(agency, list_dispatches, datastore):
    dispatch_set = set(random.sample(list_dispatches,
                                     int(len(list_dispatches)*0.75)))

    while dispatch_set:
        dispatch = random.choice(list(dispatch_set))
        is_multiple = random.choice([True, False])

        dstp_operation = set([dispatch])
        if is_multiple:
            dstp_operation = set([dstp
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
             '123'),
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

        datastore = Datastore(customs_agency=agency.key)
        datastore.store()

        officer = Officer(name=data.officer,
                          username=data.username,
                          password=data.password,
                          customs_agency=agency.key)
        officer.store()

        agency.officer = officer.key
        agency.store()

        list_dispatches = create_dispatches(agency, datastore, customers)
        operations(agency, list_dispatches, datastore)

    return
    # Customs Agency ######################################################
    ca = CustomsAgency(code='123', name='Massive Dynamic')
    ca.store()

    ca2 = CustomsAgency(code='345', name='Cyberdine')
    ca2.store()

    cavasoft = CustomsAgency(name='CavaSoft SAC')
    cavasoft.store()

    datastore_cava = Datastore(customs_agency=cavasoft.key)
    datastore_cava.store()

    officer_cava = User(username='cesarvargas@cavasoftsac.com',
                        password='123',
                        name='César Vargas',
                        is_officer=True,
                        customs_agency=cavasoft.key)
    officer_cava.store()

    cavasoft.officer = officer_cava.key
    cavasoft.store()

    # Customers ###########################################################
    queirolo = Business(
        name='SANTIAGO QUEIROLO S.A.C',
        document_number='12345678989',
        document_type='ruc',  # 20100097746
        birthday='25/01/1960',
        social_object='ELABORACION DE VINOS',
        activity='IMPORTADOR/EXPORTADOR',
        address=('AV. AVENIDA SAN MARTIN #1062 '
                 'LIMA / LIMA / PUEBLO LIBRE (MAGDALENA VIEJA)'),
        phone='4631008, 4636503, 4638777, 4616552, 4631008, 4636503',
        shareholders=[
            Business.Shareholder(name='Fidel de Santa Cruz',
                                 document_type='dni',
                                 document_number='45678989',
                                 ratio='4'),
            Business.Shareholder(name='Artemisa Kalonice',
                                 document_type='dni',
                                 document_number='69657894',
                                 ratio='7')
        ],
        is_obligated="Si",
        has_officer="No")
    queirolo.store()

    gcca = Customer(
        name='cristHian Gz. (gcca)',
        partner='Test',
        civil_state='Conviviente',
        document_number='12345678',
        document_type='dni',  # 20100097746
        birthday='06/06/2006',
        activity='Ingeniero',
        address=('Atrás del mar'),
        phone='555 5555')
    gcca.store()

    # Users ###############################################################
    offc = User(username='gcca@mail.io',
                password='789',
                name='Unamuno',
                is_officer=True,
                customs_agency=ca.key)
    offc.store()

    em1 = User(username='E-01-@gueco.io',
               password='23',
               name='Marcos')
    em1.store()

    em2 = User(username='M-02-@gueco.io',
               password='23',
               name='Lucas')
    em2.store()

    em3 = User(username='P-03-@gueco.io',
               password='23',
               name='Mateo')
    em3.store()

    em4 = User(username='L-04-@gueco.io',
               password='23',
               name='Juan')
    em4.store()

    # Stakeholders ######################################################
    metro = Linked(name='Hipermercados Metro',
                   document_type='ruc',
                   customer_type='Jurídica')
    metro.store()

    inter = Linked(name='Interbank',
                   document_type='ruc',
                   customer_type='Jurídica')
    inter.store()

    edel = Linked(name='Edelnor',
                  document_type='ruc',
                  customer_type='Jurídica')
    edel.store()

    gas = Linked(name='Transportadora de gas del Perú',
                 document_type='ruc',
                 customer_type='Jurídica')
    gas.store()

    l56 = Linked(name='Pluspetrol lote 56',
                 document_type='ruc',
                 customer_type='Jurídica')
    l56.store()

    maestro = Linked(name='Maestro Perú',
                     document_type='ruc',
                     customer_type='Jurídica')
    maestro.store()

    perpe = Linked(name='Peruana de Petróleo',
                   document_type='ruc',
                   link_type='Destinatario',
                   customer_type='Jurídica',
                   social_object='- ¿¿¿...??? -',
                   address='- ¿¿¿...??? -',
                   phone='669 7898',
                   country='Perú')
    perpe.store()

    won = Linked(name='Supermercados Wong',
                 document_type='ruc',
                 customer_type='Jurídica')
    won.store()

    losu = Linked(name='Supermercados peruanos',
                  document_type='ruc',
                  customer_type='Jurídica')
    losu.store()

    capo = Linked(represents_to='Beneficiario',
                  customer_type='Natural',
                  residence_status='No residente',
                  document_type='dni',
                  document_number='78945612',
                  issuance_country='Italia',
                  father_name='Gabriel',
                  mother_name='Capone',
                  name='Alphonse',
                  nationality='Estadounidense',
                  activity='Gánster')

    lnk1 = Linked(name='Manolete',
                  social_object='MANOA',
                  document_type='ruc',
                  customer_type='Jurídica')
    lnk1.store()

    lnk2 = Linked(name='Atlas',
                  document_type='dni',
                  document_number='69657894',
                  father_name='NI idae',
                  mother_name='Elberto',
                  customer_type='Natural')
    lnk2.store()

    # Declarants ##########################################################
    dcl1 = Declarant(name='Manolete',
                     document_type='dni',
                     document_number='45678989',
                     father_name='Sebastian',
                     mother_name='MOndragon')
    dcl1.store()

    dcl2 = Declarant(name='Atlas',
                     document_type='dni',
                     document_number='69657894',
                     father_name='NI idae',
                     mother_name='Elberto')
    dcl2.store()

    # Dispatches ##########################################################
    d = Declaration(customer=queirolo)
    d.store()
    disp0 = Dispatch(order='2014-597',
                     customer=queirolo.key,
                     declaration=d.key,
                     jurisdiction=CodeName(code='9',
                                           name='AEROPUERTO CALLAO'),
                     regime=CodeName(code='13',
                                     name='Solo Dios sabe'),
                     dam='2014-103-8012',
                     amount='56 874',
                     canal='V',
                     customs_agency=ca.key)
    disp0.store()

    d = Declaration(customer=queirolo,
                    third=Third(identification_type='Si',
                                third_type='Juridico',
                                name='IEI Municipal'))
    d.store()
    disp1 = Dispatch(reference='Debe haber una referencia!!!',
                     order='2014-601',
                     customer=queirolo.key,
                     declaration=d.key,
                     jurisdiction=CodeName(code='947',
                                           name='AEROPUERTO DE TACNA'),
                     regime=CodeName(code='10',
                                     name='Importacion para el Consumo'),
                     declarant=[dcl1, dcl2],
                     linked=[lnk1, lnk2],
                     description='Debe haber una descripcion !!!!',
                     income_date='20/12/1996',
                     canal='R',
                     customs_agency=ca.key)
    disp1.store()

    d = Declaration(customer=queirolo)
    d.store()
    disp2 = Dispatch(order='2014-604',
                     customer=queirolo.key,
                     declaration=d.key,
                     jurisdiction=CodeName(code='9',
                                           name='AEROPUERTO CALLAO'),
                     regime=CodeName(code='13',
                                     name='Solo Dios sabe'),
                     dam='2014-103-8237',
                     amount='56 874',
                     canal='V',
                     customs_agency=ca2.key)
    disp2.store()

    d = Declaration(customer=queirolo,
                    third=Third(identification_type='Si',
                                third_type='Juridico',
                                name='Muni'))
    d.store()
    disp3 = Dispatch(reference='Referencia 3',
                     order='2014-607',
                     customer=queirolo.key,
                     declaration=d.key,
                     jurisdiction=CodeName(code='947',
                                           name='AEROPUERTO DE TACNA'),
                     regime=CodeName(code='10',
                                     name='Importacion para el Consumo'),
                     declarant=[dcl1, dcl2],
                     linked=[lnk1, lnk2],
                     description='AQUI DESCRIPCION',
                     income_date='20/12/1996',
                     canal='R',
                     customs_agency=ca2.key)
    disp3.store()

    # Datastore ###########################################################
    datastore = Datastore(customs_agency=ca.key,
                          pending=[disp0.key, disp1.key],
                          accepting=[])
    datastore.store()

    # datastore2 = Datastore(customs_agency=ca.key,
    #                       pending=[disp2.key, disp3.key],
    #                       accepting=[])
    # datastore2.store()

#    operation = Operation(dispatches=[disp2.key],
#                          customs_agency=ca.key,
#                          customer=gcca.key)
#    operation.store()

    operation1 = Operation(dispatches=[disp0.key, disp1.key,
                                       disp2.key, disp3.key],
                           customs_agency=ca.key,
                           customer=queirolo.key)
    operation1.store()

    for dispatch in [disp0, disp1, disp2, disp3]:
        dispatch.operation = operation1.key
        dispatch.store()

    ########################################################################
    return
    ########################################################################

    gueco = Customs(name='Gueco', officer=offc.key,
                    employees=[em1.key, em2.key, em3.key])
    gueco.store()

    cavasoft = Customs(name='CavaSoft SAC', officer=cava.key)
    cavasoft.store()

    choice = Customs(name='Choice')
    choice.store()

    capo.store()

    disp1 = Dispatch(order='2014-601',
                     customs=gueco.key,
                     customer=queirolo.key,
                     jurisdiction=CodeName(code='947',
                                           name='AEROPUERTO DE TACNA'),
                     regime=CodeName(code='10',
                                     name='Importacion para el Consumo'),
                     dam='2014-100-8697',
                     numeration_date='18/10/2014',
                     amount='10 890,69')
    disp1.store()

    disp2 = Dispatch(order='2014-604',
                     customs=gueco.key,
                     customer=gcca.key,
                     jurisdiction=CodeName(code='154',
                                           name='AREQUIPA'),
                     regime=CodeName(code='40',
                                     name='Exportacion Definitiva'),
                     amount='56 874')
    disp2.store()


# vim: et:ts=4:sw=4
