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
                                Operation, Officer, Employee, Permissions)


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


def create_declarants():
    for declarant in declarants:
        declarant.document_number = pick_document_number_by('dni')

        declarant.store()


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
    modules = ['WEL-HASH', 'NUM-HASH', 'ANEXO2-HASH', 'INCOME-HASH']
    signals = ['WEL-HASH', 'NUM-HASH', 'ANEXO2-HASH', 'INCOME-HASH']
    while j:
        username = ''.join(random.sample(ascii_lowercase, 3))
        name = ''.join(random.sample(ascii_lowercase, 6))
        permission = Permissions(modules=modules,
                                 signals=signals)
        permission.store()
        employee = Employee(name=name,
                            username=username,
                            password='123',
                            customs_agency_key=agency.key,
                            permissions_key=permission.key)
        employee.store()
        agency.employees_key.append(employee.key)
        j -= 1
    agency.store()


def create_dispatches(agency, datastore, customers, n=30):
    from string import digits

    years = ['2014', '2015', '2016']
    channels = ['V', 'N', 'R']
    list_dispatches = []
    from datetime import datetime

    while n:
        exchange_rate = random.choice(['3.51', '3.52',
                                       '3.53', '3.54'])
        year = 2015
        month = random.randint(1, 12)
        day = random.randint(1, 28)
        rdate = datetime(year, month, day)
        num_date = datetime(int(random.choice(years)),
                            random.randint(1,12),
                            random.randint(1, 28))
        amounts = [str(x) for x in range(3999, 9999)]
        order = '%s-%s' % (random.choice(years),
                           ''.join(random.sample(digits, 5)))
        customer = random.choice(customers)
        declaration = Dispatch.Declaration(customer=customer)
        jurisdiction = random.choice(jurisdictions)
        regime = random.choice(regimes)
        dam = '%s-%s-%s-%s' %(jurisdiction.code,
                              year, regime.code,
                              ''.join(random.sample(digits, 5)))
        dispatch = Dispatch(order=order,
                            customer_key=customer.key,
                            customs_agency_key=agency.key,
                            jurisdiction=jurisdiction,
                            regime=regime,
                            stakeholders=[random.choice(stakeholders)],
                            amount=random.choice(amounts),
                            income_date=rdate,
                            dam=dam, numeration_date=num_date,
                            channel=random.choice(channels),
                            exchange_rate=exchange_rate)
        dispatch.declaration = declaration
        dispatch.store()
        datastore.pending_key.append(dispatch.key)
        datastore.store()
        list_dispatches.append(dispatch.key)
        n -= 1

    return [d for d in list_dispatches
            if d.get().customs_agency_key == agency.key]


def create_operation(agency, dstp_operation, datastore):
    counter = datastore.last_counter_operation + 1
    operation = Operation(customs_agency_key=agency.key,
                          counter=counter)
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
                                     int(len(list_dispatches)*0.65)))

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


def _data_debug():
    create_stakeholders()
    create_declarants()

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
        DCustomer('María Cayetana',
                  'dni'),
        DCustomer('Antonio Adama',
                  'dni'),
    ]

    customer_by = {
        'ruc': Business,
        'dni': Person
    }

    customers = []
    for data in init_customers:
        document_number = pick_document_number_by(data.document_type)

        customer = customer_by[data.document_type](
            name=data.name,
            document_type=data.document_type,
            document_number=document_number,
            declarants=[random.choice(declarants)])
        customer.store()
        customers.append(customer)

    Data = namedtuple('Data', ('customs_agency officer'
                               ' username password signals modules'))

    init_data = [
        Data('Massive Dynamic',
             'Nina Sharp',
             'gcca@mail.io',
             '789',
             ['WEL-HASH', 'NUM-HASH', 'ANEXO2-HASH', 'INCOME-HASH'],
             ['WEL-HASH',
              'NUM-HASH',
              'ANEXO2-HASH',
              'INCOME-HASH',
              'ANEXO 6',
              'OPLIST-HASH',
              'NEWUSER-HASH']),
        Data('Cyberdine',
             'Mice Dyson',
             'mice@cd.io',
             '123',
             ['WEL-HASH', 'NUM-HASH', 'ANEXO2-HASH', 'OPLIST-HASH'],
             ['WEL-HASH', 'NUM-HASH', 'ANEXO2-HASH', 'OPLIST-HASH'])
    ]

    for data in init_data:
        agency = CustomsAgency(name=data.customs_agency)
        agency.store()

        create_employees(agency)

        datastore = Datastore(customs_agency_key=agency.key)
        datastore.store()

        permission = Permissions(modules=data.modules,
                                 signals=data.signals)
        permission.store()

        officer = Officer(name=data.officer,
                          username=data.username,
                          password=data.password,
                          customs_agency_key=agency.key,
                          permissions_key=permission.key)
        officer.store()

        agency.officer_key = officer.key
        agency.store()

        list_dispatches = create_dispatches(agency, datastore, customers)
        operations(agency, list_dispatches, datastore)

    create_autocomplete()  # TODO: Remove when update domain model

    # HARDCODED data
    _data_deploy()


def _data_deploy():
    if CustomsAgency.find(name='CavaSoft SAC'):
        return

    ca = CustomsAgency(name='CavaSoft SAC')
    ca.store()

    ds = Datastore(customs_agency_key=ca.key)
    ds.store()

    perms = Permissions(modules=['WEL-HASH',
                                 'NUM-HASH',
                                 'ANEXO2-HASH',
                                 'INCOME-HASH',
                                 'OPLIST-HASH',
                                 'NEWUSER-HASH'],
                        signals=[])
    perms.store()

    of = Officer(customs_agency_key=ca.key,
                 name='César Vargas',
                 username='cesarvargas@cavasoftsac.com',
                 password='123',
                 permissions_key=perms.key)
    ca.officer_key = of.store()
    ca.store()


create_sample_data = _data_debug if plaft.config.DEBUG else _data_deploy


# LIST

raw_regimes = (
    ('Importacion para el Consumo', '10'),
    ('Reimportacion en el mismo Estado', '36'),
    ('Exportacion Definitiva', '40'),
    ('Exportacion Temporal para Reimportacion en el mismo Estado', '51'),
    ('Exportacion Temporal para Perfeccionamiento Pasivo', '52'),
    ('Admision temporal para Perfeccionamiento Activo', '21'),
    ('Admision temporal para Reexportacion en el mismo Estado', '20'),
    ('Drawback', '41'),
    ('Reposicion de Mercancias con Franquicia Arancelaria', '41'),
    ('Deposito Aduanero', '70'),
    ('Reembarque', '89'),
    ('Transito Aduanero', '80'),
    ('Importacion Simplificada', '18'),
    ('Exportacion Simplificada', '48'),
    ('Material de Uso Aeronautico', '71'),
    ('Destino Especial de Tienda Libre (DUTY FREE)', '72'),
    ('Rancho de naves', '99'),
    ('Material de Guerra', '99'),
    ('Vehiculos para Turismo', '99'),
    ('Material uso Aeronautico', '99'),
    ('Ferias o Exposiciones Internacionales', '20')
)

regimes = tuple(CodeName(name=j[0], code=j[1]) for j in raw_regimes)


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


raw_declarants = (
    # (name, address)
    ('Tony Stark', 'Iron Man'),
    ('Bruce Wayne', 'Batman'),
    ('Charles Xavier', 'X-men'),
    ('Mister Fantastic', 'Fantastic Four'),
    ('Michael Holt', 'Mister Terrific'),
    ('Lex Luthor', 'Superman'),
    ('Green Goblin', 'Spider-Man'),
    ('Penguin', 'Batman'),
    ('Kyle Rayner', 'Green Lantern'),
    ('Kingpin', 'Marvel Comics')
)

declarants = tuple(Declarant(name=j[0],
                             address=j[1])
                   for j in raw_declarants)

raw_alerts_1=(
    ('1.  El cliente, para efectos de su identificación,'
     ' presenta información inconsistente o de dificil'
     ' verificación por parte del sujeto obligado.'),
    ('2.  El cliente declara o registra la misma dirección'
     ' que la de otras personas con las que no tiene relación'
     ' o vínculo aparente.'),
    ('3.  Existencia de indicios de que el ordenante (propietario'
     '/titular del bien o derecho) ó el beneficiario (adquirente o'
     ' receptor del bien o derecho) no actúa por su cuenta y que'
     ' intenta ocultar la identidad del ordenante o beneficiario real.'),
    ('4.  El cliente presenta una inusual despreocupación por los'
     ' riesgos que asume o los importes involucrados en el despacho'
     ' aduanero de mercancias o los costos que implica la operación.'),
    ('5.  El cliente realiza operaciones de forma sucesiva y/o reiterada.'),
    ('6.  El cliente realiza constantemente operaciones y de modo inusual'
     ' usa o pretende utilizar dinero en efectivo como único medio de pago.'),
    ('7.  El cliente se rehusa a llenar los formularios o proporcionar la'
     ' información requerida por el sujeto obligado, o se niega a realizar'
     ' la operación tan pronto se le solicita.'),
    ('8.  Las operaciones realizadas por el cliente no corresponden'
     ' a su actividad económica.'),
    ('9.  El cliente está siendo investigado o procesado por el delito'
     ' de lavado de activos, delitos precedentes, el delito de'
     ' financiamiento del terrorismo y sus delitos conexos, y se toma'
     ' conocimiento de ello por los medios de difusión pública u'
     ' otros medios.'),
    ('10. Clientes entre los cuales no hay ninguna relación de'
     ' parentesco, financiera o comercial, sean personas naturales'
     ' o jurídicas, sin embargo son representados por una misma persona.'
     ' Se debe prestar especial atención cuando dichos clientes tengan'
     ' fijado sus domicilios en el extranjero o en paraísos fiscales.'),
    ('11. El cliente realiza frecuentemente operaciones por sumas de'
     ' dinero que no guardan relación con la ocupación que declara tener.'),
    ('12. Solicitud  del cliente de realizar despachos aduaneros de'
     ' mercancias en condiciones o valores que no guardan relación con'
     ' las actividades del dueño o consignatario, o en las condiciones'
     ' habituales del mercado.'),
    ('13. Solicitud del cliente de dividir los pagos por la prestación'
     ' del servicio, generalmente, en efectivo.'),
    ('14. Personas naturales o jurídicas, incluyendo sus accionistas,'
     ' socios, asociados, socios fundadores, gerentes y directores,'
     ' que figuren en alguna lista internacional de las Naciones Unidas,'
     ' OFAC o similar.'),
    ('15. El cliente presenta una inusual despreocupación por la'
     ' presentación o estado de su mercancía o carga y/o de'
     ' las comisiones y costos que implica la operación.'),
    ('16. El cliente solicita ser excluido del registro de operaciones.'),
    ('17. El cliente asume el pago de comisiones, impuestos y cualquier'
     ' otro costo o tributo generado no sólo por la realización de sus'
     ' operaciones, sino la de terceros o a las de otras operaciones'
     ' aparentemente no relacionadas.'),
    ('18. El cliente realiza frecuentes o significativas operaciones y'
     ' declara no realizar o no haber realizado actividad económica alguna.')
)

raw_alerts_2=(
    ('1 Existencia de indicios de exportaciones o importación ficticia'
     ' de bienes y/o uso de documentos presuntamente falsos o inconsistentes'
     ' con los cuales se pretenda acreditar estas operaciones de comercio'
     ' exterior.'),
    ('2 Existencia de indicios respecto a que la cantidad'
     ' de mercancía importada es superior a la declarada.'),
    ('3 Existencia de indicios referidos a que la cantidad'
     ' de mercancía exportada es inferior a la declarada.'),
    ('4 Cancelaciones reiteradas de órdenes de embarque.'),
    ('5 Importaciones / exportaciones de gran volumen y/o valor,'
     ' realizadas por personas no residentes en el Perú, que no'
     ' tengan relación con su actividad económica.'),
    ('6 Existencia de indicios de sobrevaloración y/o subvaluación'
     ' de mercancías importadas y/o exportadas.'),
    ('7 Abandono de mercancías importadas.'),
    ('8 Importación de bienes suntuarios (entre otros, obras'
     ' de arte, piedras preciosas, antigüedades, vehículos lujosos)'
     ' que no guardan relación con el giro o actividad del cliente.'),
    ('9 Importaciones / exportaciones desde o hacia paraísos fiscales,'
     ' o países considerados no cooperantes por el GAFI o sujetos'
     ' a sanciones OFAC.'),
    ('10  Importaciones y/o exportaciones realizadas por extranjeros'
     ' sin actividad permanente en el país.'),
    ('11  Importaciones y/o exportaciones realizadas por personas'
     ' naturales o jurídicas sin trayectoria en la actividad comercial'
     ' del producto importado y/o exportado.'),
    ('12  Importaciones y/o exportaciones realizadas por personas'
     ' jurídicas que tienen socios jovenes sin experiencia aparente'
     ' en el sector.'),
    ('13  Importación o almacenamiento de sustancias que se presuma'
     ' puedan ser utilizadas para la producción y/o fabricación'
     ' de estupefacientes.'),
    ('14  Mercancías que ingresan documentalmente al país, pero'
     ' no físicamente sin causa aparente o razonable.'),
    ('15  Despachos realizados para una persona jurídica que tiene'
     ' la misma dirección de otras personas jurídicas, las que están'
     ' vinculadas por contar con el mismo representante, sin ningún'
     ' motivo legal o comercial ó económico aparente.'),
    ('16  Bienes dejados en depósito que totalizan sumas'
     ' importantes y que no corresponden al perfil de la'
     ' actividad del cliente.'),
    ('17  Existen indicios de que el valor de los bienes dejados'
     ' en depsito no corresponde al valor razonable del mercado.'),
    ('18  Clientes cuyas mercancías presentan constantes abandonos legales'
     ' o diferencias en el valor y/o cantidad de la mercancía, en las'
     ' extracciones de muestras o en otros controles exigidos por'
     ' la regulación vigente.'),
    ('19  Importaciones y/o exportaciones realizadas de/a principales'
     ' países consumidores de cocaína.'),
    ('20  El instrumento o la orden de pago, giro o remesa que'
     ' cancele la importación figure a favor una persona natural'
     ' o jurídica, distinta al proveedor del exterior, sin que exista'
     ' una justificación aparente, en caso el oficial de cumplimiento'
     ' cuente con esta información.'),
    ('21  El pago de la importación se ha destinado a un país diferente'
     ' al país de origen de la mercancía, sin una justificación aparente.'),
    ('22  Existen indicios referidos a que se habrian presentado'
     ' documentos falsos o inconsistentes, con los cuales se pretenda'
     ' acreditar una operación y/o exportación.'),
    ('23  El pago de la exportación provenga de persona diferente'
     ' al comprador/cliente en el exterior o que figure como tal la'
     ' persona natural o jurídica que realizó la exportación, sin que'
     ' exista una justificación aparente, en caso el oficial de'
     ' cumplimiento cuente con esta información.'),
    ('24  Personas naturales o jurídicas que hayan realizado exportación'
     ' de bienes, sin embargo no solicitan la restitución de derechos'
     ' arancelarios - drawback, aun cuando cumplen los requisitos'
     ' exigidos por la normativa vigente para acogerse a este beneficio.'),
    ('25  Solicitud de restitución de derechos arancelarios - drawback,'
     ' por exportaciones de productos cuyos valores, aparentemente y de'
     ' acuerdo a algunos indicios, se encontrarían por encima del precio'
     ' del mercado.'),
    ('26  Envíos habituales de pequeños paquetes de mercancías a nombre'
     ' de una misma persona o diferentes personas con el mismo domicilio.'),
    ('27  Transferencia de certificados de depósito entre personas naturales'
     ' o jurídicas cuya actividad no guarde relación con los bienes'
     ' representados en dichos instrumentos.'),
    ('28  Solicitud de empleo de almacenes de campo sin justificación'
     ' aparente, dado el tipo de bien sobre el que se pretende realizar'
     ' el depósito.'),
    ('29  El documento de transporte viene a nombre de una persona'
     ' natural o jurídica reconocida y luego es endosado a un tercero'
     ' sin actividad economica o sin trayectoria en el sector.'),
    ('30  El importador dificulta o impide el reconocimiento físico'
     ' de la mercancia.'),
    ('31  El cliente realiza operaciones de comercio exterior que'
     ' no guardan relación con el giro del negocio.'),
    ('32  Existencia de pagos declarados como anticipos de futuras'
     ' importaciones o exportaciones por sumas elevadas, en relacion'
     ' a las operaciones habituales realizadas por el cliente, sin'
     ' embargo existen indicios de que posteriormente no se realizó'
     ' la respectiva importacion o exportacion.'),
    ('33  Importadores o exportadores de bienes inusuales o nuevos'
     ' que de manera súbita o esporádica efectuen operaciones que no'
     ' guarden relacion por su magnitud con la clase del negocio o con'
     ' su nueva actividad comercial, o no tengan la infraestructura'
     ' suficiente para ello.')
)


# vim: et:ts=4:sw=4
