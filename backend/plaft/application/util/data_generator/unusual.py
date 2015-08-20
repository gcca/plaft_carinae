# encoding: utf-8

identification = (
    'DATOS DE IDENTIFICACIÓN',
    (
        ('1', 'Código del sujeto obligado otorgado por la UIF',
              lambda a: '-'),
        ('2', 'Código del oficial de cumplimiento otorgado por la UIF',
              lambda a: '-')
    )
)

unusual = (
    'DATOS DE IDENTIFICACIÓN DE LA OPERACIÓN INUSUAL',
    (
        ('3', ('Número de operación inusual: Consignar el número de'
               ' secuencia correspondiente al registro de la operación'
               ' inusual debiendo empezar en el número uno (1), de acuerdo'
               ' al formato siguiente: (año - número)'), lambda d: '-'),
        ('4', ('Número de registro interno del sujeto obligado:'
               ' Consignar el número de la Declaración Aduanera de'
               ' Mercancias (DAM) correspondiente a la operación inusual'
               ' que se registra.'), lambda d: d.dam),
        ('5', ('Fecha de la operación inusual: Consignar la fecha de'
               ' numeración de la mercancía (dd/mm/aaaa)'),
         lambda d: str(d.numeration_date))
    )
)

person = (
    ('DATOS DE IDENTIFICACIÓN DE LAS PERSONAS INVOLUCRADAS EN LAS'
     ' OPERACIONES INUSUALES (consignar los datos consignados en esta'
     ' sección por cada persona involucrada en la operación inusual)'),
    (
        ('6', ('La persona en cuyo nombre se realiza la operación es:'
               ' (1) proveedor del extranjero (ingreso de mercancía),'
               ' (2) Importador (ingreso de mercancía),ó Exportador'
               ' (salida de mercancía) ó Destinatario del embarque'
               ' (salida de mercancía).'), lambda c: c.link_type),
        ('7', ('Tipo de persona: (1) Persona Natural ó (2) Persona Jurídica.'
               ' Si consignó la opción (2) no llenar los items 08 al 13 ni'
               ' los items del 15 al 22.'),
         lambda c: ('Persona Jurídica'
                    if c.document_type == 'ruc'
                    else 'Persona Natural')),
        ('8', ('Tipo de documento de identidad. Consignar el'
               ' código de acuerdo a la Tabla N° 1.'),
         lambda c: ('No aplica'
                    if c.document_type == 'ruc'
                    else (c.document_type).upper())),
        ('9', 'Número de documento de identidad.',
         lambda c: ('No aplica'
                    if c.document_type == 'ruc'
                    else c.document_number)),
        ('10', 'Condición de residencia: (1) Residente ó (2) No Residente.',
         lambda c: ('No aplica'
                    if c.document_type == 'ruc'
                    else c.condition)),
        ('11', 'País de emisión del documento (en caso corresponda).',
         lambda c: ('No aplica'
                    if c.document_type == 'ruc'
                    else c.issuance_country)),
        ('12', 'Persona es PEP: (1)Si ó (2)No.',
               lambda c: ('No aplica'
                          if c.document_type == 'ruc'
                          else 'Si' if c.is_pep else 'No')),
        ('13', ('En caso en el item 12 haya consignado la opción (1),'
                ' indicar el cargo público que desempeña.'),
         lambda c: ('No aplica'
                    if c.document_type == 'ruc'
                    else c.employment)),
        ('14', 'Apellido paterno o razón social (persona jurídica).',
         lambda c: (c.name if c.document_type == 'ruc'
                    else c.father_name)),
        ('15', 'Apellido materno.', lambda c: ('No aplica'
                                               if c.document_type == 'ruc'
                                               else c.mother_name)),
        ('16', 'Nombres.', lambda c: ('No aplica'
                                      if c.document_type == 'ruc'
                                      else c.name)),
        ('17', 'Nacionalidad.', lambda c: ('No aplica'
                                           if c.document_type == 'ruc'
                                           else c.nationality)),
        ('18', 'Fecha de Nacimiento (dd/mm/aaaa).',
         lambda c: ('No aplica' if c.document_type == 'ruc'
                    else c.birthday)),
        ('19', ('Ocupación, oficio o profesión (persona natural) :'
                ' Consignar los códigos de acuerdo a la Tabla No 2.'),
         lambda c: ('No aplica' if c.document_type == 'ruc'
                    else c.activity)),
        ('20', ('Descripción de la ocupación, oficio o profesión'
                ' la opción otros.'), lambda c: 'No aplica'),
        ('21', 'Empleador (En caso de ser dependiente).',
         lambda c: ('No aplica' if c.document_type == 'ruc'
                    else c.employer)),
        ('22', ('Ingresos promedios mensuales aproximados '
                '(En caso de ser dependiente).'),
         lambda c: ('No aplica' if c.document_type == 'ruc'
                    else c.average_income)),
        ('23', ('Objeto social de la persona jurídica'
                '(Consignar la actividad principal).'),
         lambda c: (c.social_object if c.document_type == 'ruc'
                    else 'No aplica')),
        ('24', ('Cargo (si aplica): Consignar los códigos de'
                ' acuerdo a la Tabla No 3.'), lambda c: 'No aplica'),
        ('25', 'Nombre y número de la vía de la dirección.',
         lambda c: c.address),
        ('26', ('Teléfono de la persona en cuyo nombre se realiza'
                ' la operación.'), lambda c: c.phone),
        ('27', ('Condición en la que interviene en la operación'
                ' inusual: (1) Involucrado ó (2) Vinculado'),
         lambda c: c.unusual_condition),
        ('28', ('Describir la condición en la que interviene en la'
                ' operación inusual.'), lambda c: c.unusual_operation)

    )
)

operation = (
    ('DATOS RELACIONADOS A LA DESCRIPCIÓN DE LA OPERACIÓN INUSUAL'),
    (
        ('29', ('Tipo de fondos con que se realizó la operación:'
                ' consignar el código de acuerdo a la Tabla N° 4.'),
         lambda d: d.declaration.customer.money_source_type),
        ('30', ('Tipo de operación: consignar el código de acuerdo'
                ' a la Tabla N° 5: Tipos de Operación'),
         lambda d: d.regime.name),
        ('31', ('Descripción del tipo de operación en caso según la tabla'
                ' de operaciones se haya consignado el código de "Otros"'),
         lambda d: 'No aplica'),
        ('32', 'Descripción de las mercancías involucradas en la operación',
         lambda d: d.description),
        ('33', 'Origen de los fondos involucrados en la operación.',
         lambda d: d.declaration.customer.money_source),
        ('34', ('Moneda en que se realizo la operacion: S=Nuevos Soles,'
                ' USD =Dólares Americanos,E= Euros y O= Otra(Detallar en'
                ' item siguiente)'), lambda d: 'USD'),
        ('35', 'Descripción del tipo de moneda en caso sea "Otra"',
         lambda d: 'No aplica'),
        ('36', ('Monto de la operación: Consignar el valor de la mercancía'
                ' correspondiente a la operación de comercio exterior que se'
                ' haya realizado. Los montos deberán estar expresados en'
                ' nuevos soles con céntimos. Para aquellas operaciones'
                ' realizadas con alguna moneda extranjera diferente a la'
                ' indicada, se deberán convertir a dólares, según el tipo'
                ' de cambio que la entidad tenga vigente el día que se'
                ' realizó la operación'), lambda d: str(d.amount_soles)),
        ('37', ('Tipo de cambio: consignar el tipo de cambio respecto a'
                ' la moneda nacional, en los casos en los que la operación'
                ' haya sido registrada en moneda diferente a soles, dólares'
                ' o euros. El tipo de cambio será el que la entidad tenga'
                ' vigente el día que se realizó la operación.'),
         lambda d: d.exchange_rate),
        ('38', ('Código de país de origen: para las operaciones'
                ' relacionadas con importación de bienes, para lo cual'
                ' deben tomar la codificación publicada por la SBS.'),
         lambda d: (d.stakeholders[0].country if not d.is_out
                    else 'No aplica')),
        ('39', ('Código de país de destino: para las operaciones'
                ' relacionadas con exportación de bienes, para lo cual'
                ' deben tomar la codificación publicada por la SBS.'),
         lambda d: (d.stakeholders[0].country if d.is_out else 'No aplica')),
        ('40', ('Descripción de la operación(Señale los argumentos que'
                ' lo llevaron a calificar como inusual la operación).'),
         lambda d: d.description),
        ('41', ('La operación ha sido calificada como sospechosa (1)Si,'
                ' (2)No'), lambda d: 'Si' if d.is_suspects else 'No'),
        ('42', ('En caso en el item 41 haya consignado la opción (1),'
                ' indicar el número de ROS con el que se remitió a la UIF.'),
         lambda d: d.ros if d.is_suspects else 'No aplica'),
        ('43', ('En caso en el item 41 haya consignado la opción (2)'
                ' describir los argumentos por los cuales esta operación'
                ' no fue calificada como sospechosa.'),
         lambda d: (d.suspects_by if not d.is_suspects else 'No aplica'))
    )
)

alerts = (
    ('SEÑALES DE ALERTA IDENTIFICADAS'
     ' (Se debe consignar estos datos por cada señal de alerta)'),
    (
        ('44', 'Código de la señal de alerta',
         lambda a: a.info.section + a.info.code),
        ('45', 'Descripción de la señal de alerta',
         lambda a: a.info.description),
        ('46', ('Fuente de la señal de alerta: Sistema de'
                ' Monitoreo (1), Área Comercial (2), Análisis del'
                ' SO (3), Medio Periodístico (4) y Otras fuentes (5).'),
         lambda a: a.source),
        ('47', ('En caso en el item 46 se haya consignado la'
                ' opción 5 describir la fuente'),
         lambda a: (a.description_source if a.source is 'Otras fuentes'
                    else 'No aplica'))
    )
)


# vim: et:ts=4:sw=4
