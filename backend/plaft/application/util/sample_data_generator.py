# encoding: utf-8
"""
.. module:: plaft.application.util
   :synopsis: Provides sample data.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from __future__ import unicode_literals
from plaft.domain.model import (Officer, Employee, Dispatch, CodeName,
                                  Customer, Third, Declarant, Linked)


def create_sample_data():
    ## Customers ###########################################################
    queirolo = Customer(
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
            Customer.Shareholder(name='Fidel de Santa Cruz',
                                 document_type='dni',
                                 document_number='45678989',
                                 ratio='4'),
            Customer.Shareholder(name='Artemisa Kalonice',
                                 document_type='dni',
                                 document_number='69657894',
                                 ratio='7')
        ],
        is_obligated = "Si",
        has_officer = "No",
        third = Third(identification_type='Si',
                      third_type='Juridico',
                      name='IEI Municipal'))
    queirolo.store()

    gcca = Customer(
        name='cristHian Gz. (gcca)',
        document_number='12345678',
        document_type='dni',  # 20100097746
        birthday='06/06/2006',
        activity='Ingeniero',
        address=('Atrás del mar'),
        phone='555 5555')
    gcca.store()


    ## Users ###############################################################
    offc = Officer(username='gcca@mail.io',
                   password='789',
                   name='Unamuno')
    offc.store()

    em1 = Employee(username='E-01-@gueco.io',
                   password='23',
                   name='Marcos')
    em1.store()

    em2 = Employee(username='M-02-@gueco.io',
                   password='23',
                   name='Lucas')
    em2.store()

    em3 = Employee(username='P-03-@gueco.io',
                   password='23',
                   name='Mateo')
    em3.store()

    em4 = Employee(username='L-04-@gueco.io',
                   password='23',
                   name='Juan')
    em4.store()

    cava = Officer(username='cesarvargas@cavasoft.com',
                   password='123',
                   name='César Vargas')
    cava.store()


    ## Stakeholders ######################################################
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
                  customer_type= 'Juridica')
    lnk1.store()

    lnk2 = Linked(name='Atlas',
                  document_type='dni',
                  document_number='69657894',
                  father_name= 'NI idae',
                  mother_name= 'Elberto',
                  customer_type= 'Natural')
    lnk2.store()


    ## Declarants ##########################################################
    dcl1 = Declarant(name='Manolete',
             document_type='dni',
             document_number='45678989',
             father_name = 'Sebastian',
             mother_name = 'MOndragon')
    dcl1.store()

    dcl2 = Declarant(name='Atlas',
             document_type='dni',
             document_number='69657894',
             father_name= 'NI idae',
             mother_name= 'Elberto')
    dcl2.store()


    ## Dispatches ##########################################################
    disp1 = Dispatch(reference='Debe haber una referencia!!!',
                     order='2014-601',
                     declaration=queirolo,
                     jurisdiction=CodeName(code='947',
                                           name='AEROPUERTO DE TACNA'),
                     regime=CodeName(code='10',
                                     name='Importacion para el Consumo'),
                     declarant=[dcl1,dcl2],
                     linked=[lnk1,lnk2],
                     description='Debe haber una descripcion !!!!',
                     income_date='20/12/1996')
    disp1.store()

    disp2 = Dispatch(order='2014-604',
                     declaration=gcca,
                     jurisdiction=CodeName(code='9',
                                           name='AEROPUERTO CALLAO'),
                     dam='2014-103-8237',
                     amount='56 874',
                     canal='V')
    disp2.store()

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
