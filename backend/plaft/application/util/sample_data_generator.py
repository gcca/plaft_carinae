# encoding: utf-8
"""
.. module:: plaft.application.util
   :synopsis: Provides sample data.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from __future__ import unicode_literals
from plaft.domain.model import (User, Dispatch, CodeName, Declaration,
                                Customer, Third, Declarant, Linked, Business,
                                Datastore, CustomsAgency)


def create_sample_data():
    ## Customs Agency ######################################################
    ca = CustomsAgency(
        code= '123',
        name= 'Agencia testing')
    ca.store()

    ca2 = CustomsAgency(
        code= '345',
        name= 'Testing agency')
    ca2.store()


    ## Customers ###########################################################
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
        is_obligated = "Si",
        has_officer = "No")
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


    ## Users ###############################################################
    offc = User(username='gcca@mail.io',
                   password='789',
                   name='Unamuno',
                   is_officer=True,
                   customs_agency = ca.key)
    offc.store()

    offc2 = User(username='gcca2@mail.io',
                   password='123',
                   name='Unamuno reloaded',
                   is_officer=True,
                   customs_agency = ca2.key)
    offc2.store()

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

    cava = User(username='cesarvargas@cavasoft.com',
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
                  customer_type= 'Jurídica')
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
    d = Declaration(customer=gcca)
    d.store()
    disp0 = Dispatch(order='2014-597',
                     customer=gcca.key,
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
                    third=Third(
                    identification_type='Si',
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
                     declarant=[dcl1,dcl2],
                     linked=[lnk1,lnk2],
                     description='Debe haber una descripcion !!!!',
                     income_date='20/12/1996',
                     canal='R',
                     customs_agency=ca.key)
    disp1.store()

    d = Declaration(customer=gcca)
    d.store()
    disp2 = Dispatch(order='2014-604',
                     customer=gcca.key,
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
                    third=Third(
                    identification_type='Si',
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
                     declarant=[dcl1,dcl2],
                     linked=[lnk1,lnk2],
                     description='AQUI DESCRIPCION',
                     income_date='20/12/1996',
                     canal='R',
                     customs_agency=ca2.key)
    disp3.store()


    ## Datastore ###########################################################
    datastore = Datastore(customs_agency=ca.key,
                          pending=[disp0.key, disp1.key],
                          accepting=[])
    datastore.store()

    # datastore2 = Datastore(customs_agency=ca.key,
    #                       pending=[disp2.key, disp3.key],
    #                       accepting=[])
    # datastore2.store()


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
