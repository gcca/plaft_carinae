# encoding: utf-8
"""
.. module:: plaft.application.util
   :synopsis: Provides sample data.

.. moduleauthor:: Gonzales Castillo, Cristhian A. <cristhian.gz@aol.com>


"""

from __future__ import unicode_literals
# from plaft.domain.model import (Officer, Customs, Business, Person,
#                                 Document, Stakeholder, Employee, Dispatch,
#                                 CodeName)
from plaft.domain.model import Officer, Employee, Customer

def users():
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





    queirolo = Customer(name='SANTIAGO QUEIROLO S.A.C',
                        document_number='12345678989',  # 20100097746
                        document_type='ruc')
    queirolo.store()

    gcca = Customer(
        name='cristHian Gz. (gcca)',
        document_number='12345678',  # 20100097746
        document_type='dni')
    gcca.store()


    return





    gueco = Customs(name='Gueco', officer=offc.key,
                      employees=[em1.key, em2.key, em3.key])
    gueco.store()

    cavasoft = Customs(name='CavaSoft SAC', officer=cava.key)
    cavasoft.store()

    choice = Customs(name='Choice')
    choice.store()


    queirolo = Business(
        name='SANTIAGO QUEIROLO S.A.C',
        document=Document(type='ruc', number='12345678989'),  # 20100097746
        birthday='25/01/1960',
        social_object='ELABORACION DE VINOS',
        activity='IMPORTADOR/EXPORTADOR',
        address=('AV. AVENIDA SAN MARTIN #1062 '
                 'LIMA / LIMA / PUEBLO LIBRE (MAGDALENA VIEJA)'),
        phone='4631008, 4636503, 4638777, 4616552, 4631008, 4636503',
        shareholders=[
            Business.Shareholder(name='Fidel de Santa Cruz',
                                 document=Document(type='dni',
                                                   number='45678989'),
                                 ratio='4'),
            Business.Shareholder(name='Artemisa Kalonice',
                                 document=Document(type='dni',
                                                   number='69657894'),
                                 ratio='8')
        ])
    queirolo.store()

    gcca = Person(
        name='cristHian Gz. (gcca)',
        document=Document(type='dni', number='12345678'),  # 20100097746
        birthday='06/06/2006',
        activity='Ingeniero',
        address=('Atrás del mar'),
        phone='555 5555')
    gcca.store()


    metro = Stakeholder(name='Hipermercados Metro',
                        customer_type='Jurídica')
    metro.store()

    inter = Stakeholder(name='Interbank',
                        customer_type='Jurídica')
    inter.store()

    edel = Stakeholder(name='Edelnor',
                       customer_type='Jurídica')
    edel.store()

    gas = Stakeholder(name='Transportadora de gas del Perú',
                      customer_type='Jurídica')
    gas.store()

    l56 = Stakeholder(name='Pluspetrol lote 56',
                      customer_type='Jurídica')
    l56.store()

    maestro = Stakeholder(name='Maestro Perú',
                          customer_type='Jurídica')
    maestro.store()

    perpe = Stakeholder(name='Peruana de Petróleo',
                        link_type='Destinatario',
                        customer_type='Jurídica',
                        social_object='- ¿¿¿...??? -',
                        address='- ¿¿¿...??? -',
                        phone='669 7898',
                        country='Perú')
    perpe.store()

    won = Stakeholder(name='Supermercados Wong',
                      customer_type='Jurídica')
    won.store()

    losu = Stakeholder(name='Supermercados peruanos',
                       customer_type='Jurídica')
    losu.store()


    capo = Stakeholder(represents_to='Beneficiario',
                       customer_type='Natural',
                       residence_status='No residente',
                       document=Document(type='005', number='78945612'),
                       issuance_country='Italia',
                       father_name='Gabriel',
                       mother_name='Capone',
                       name='Alphonse',
                       nationality='Estadounidense',
                       activity='Gánster')
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
