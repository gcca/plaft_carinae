# encoding: utf-8

declarant = (
    ('9', ('La persona que solicita o físicamente realiza la operación'
           ' actúa en representación del: (1) Ordenante o (2) Beneficiario')),
    ('10', ('Condición de residencia de la persona que solicita o'
            ' físicamente realiza la operación: (1) Residente o (2)'
            ' No residente')),
    ('11', ('Tipo de documento la persona que solicita o físicamente '
            'realiza la operación (Consignar el código de acuerdo a la'
            ' Tabla N° 1)')),
    ('12', ('Numero de documento de la persona que solicita o fisicamente'
            ' realiza la operacion.')),
    ('13', ('País de emisión del documento de la persona que solicita o'
            ' físicamente realiza la operación, en caso sea un documento'
            ' emitido en el extranjero')),
    ('14', ('Apellido paterno de la persona que solicita o físicamente'
            ' realiza la operación')),
    ('15', ('Apellido materno de la persona que solicita o físicamente'
            ' realiza la operación.')),
    ('16', ('Nombres de la persona que solicita o físicamente realiza'
            ' la operación')),
    ('17', ('Nacionalidad de la persona que solicita o físicamente'
            ' realiza la operación.')),
    ('18', ('Ocupación, oficio o profesión de la persona que solicita'
            ' o físicamente realiza la operación: Consignar los códigos'
            ' de acuerdo a la Tabla N° 2')),
    ('19', ('Descripción de la ocupación, oficio o profesión de la persona'
            ' que solicita o físicamente realiza la operación en caso en'
            ' el ítem anterior se haya consignado la opción otros.')),
    ('20', ('Código CIIU de la ocupación de la persona que solicita o'
            ' físicamente realiza la operación')),
    ('21', ('Cargo de la persona que solicita o físicamente realiza la'
            ' operación (si aplica): Consignar los códigos de acuerdo a'
            ' la Tabla N° 3')),
    ('22', ('Nombre y número de la vía de la dirección de la persona que'
            ' solicita o físicamente realiza la operación')),
    ('23', ('Código UBIGEO del Departamento, provincia y distrito de la'
            ' dirección de la persona que solicita o físicamente realiza'
            ' la operación: de acuerdo a la codificación vigente y'
            ' publicada por el INEI')),
    ('24', ('Teléfono de la persona que solicita o físicamente realiza'
            ' la operación'))
)

customer = (
    ('25', ('La persona en cuyo nombre se realiza la operación es: (1)'
            ' proveedor del extranjero (ingreso de mercancía), (2)'
            ' Exportador (salida de mercancía). Si es proveedor del'
            ' extranjero sólo consignar nombres y apellidos completos'
            ' (persona natural), razón social (personas jurídicas) y'
            ' dirección. Si es el exportador, consignar todos los datos'
            ' detallados en esta sección.')),
    ('26', ('La persona en cuyo nombre se realiza la operación ha sido'
            ' representado por: (1) Representante legal (2) Apoderado'
            ' (3) Mandatario (4) Él mismo.')),
    ('27', ('Condición de residencia de la persona en cuyo nombre se'
            ' realiza la operación: (1) Residente, (2) No residente')),
    ('28', ('Tipo de persona en cuyo nombre se realiza la operación: (1)'
            ' Persona Natural, (2) Persona Jurídica. Si consignó la opción'
            ' (2) no llenar los items 29 al 31 ni los items 34 al 38')),
    ('29', ('Tipo de documento de la persona en cuyo nombre se realiza la
            'operación. Consignar el código de acuerdo a la Tabla N° 1.')),
    ('30', ('Número de documento de la persona en cuyo nombre se realiza'
            ' la operación.')),
    ('31', ('País de emisión del documento de la persona en cuyo nombre'
            ' se realiza la operación, en caso sea un documento emitido'
            ' en el extranjero.')),
    ('32', ('Número de RUC de la persona en cuyo nombre se realiza '
            'la operación.')),
    ('33', ('Apellido paterno o razón social (persona jurídica) de la'
            ' persona en cuyo nombre se realiza la operación')),
    ('34', ('Apellido materno de la persona en cuyo nombre se realiza '
            'la operación')),
    ('35', ('Nombres de la persona en cuyo nombre se realiza la operación')),
    ('36', ('Nacionalidad de la persona en cuyo nombre se realiza la '
            'operación')),
    ('37', ('Ocupación, oficio o profesión de la persona en cuyo nombre '
            'se realiza la operación (persona natural): Consignar los '
            'códigos de acuerdo a la Tabla N° 2')),
    ('38', ('Descripción de la ocupación, oficio o profesión de la persona '
            'en cuyo nombre se realiza la operación en caso en el ítem '
            'anterior se haya consignado la opción otros.')),
    ('39', ('Actividad económica de la persona en cuyo nombre se realiza '
            'la operación (persona jurídica u otras formas de organización'
            ' o asociación que la Ley establece):Consignar la actividad'
            ' principal')),
    ('40', ('Código CIIU de la ocupación de la persona en cuyo nombre se'
            ' realiza la operación')),
    ('41', ('Cargo de la persona en cuyo nombre se realiza la operación '
            '(si aplica): consignar los códigos de acuerdo a la '
            'Tabla N° 3.')),
    ('42', ('Nombre y número de la vía de la dirección de la persona en'
            ' cuyo nombre se realiza la operación')),
    ('43', ('Código UBIGEO del Departamento, provincia y distrito de '
            'la dirección de la persona en cuyo nombre se realiza la '
            'operación: de acuerdo a la codificación vigente y publicada'
            ' por el INEI.')),
    ('44', ('Teléfono de la persona en cuyo nombre se realiza la operación.'))
)

stakeholder = (
    ('45', ('La persona a favor de quien se realiza la operación es: (1)'
            ' Importador (ingreso de mercancía) ó (2) Destinatario del'
            ' embarque (salida de mercancía). Si es el destinatario del'
            ' embarque sólo consignar nombres y apellidos completos'
            ' (persona natural), razón social (personas jurídicas) y '
            'dirección. Si es el importador, consignar todos los datos '
            'detallados en esta sección.')),
    ('', ('')),
    ('46', ('Condición de residencia de la persona a favor de quien se '
            'realiza la operación: (1) Residente ó (2) No residente.')),
    ('47', ('Tipo de persona a favor de quien se realiza la operación: (1)'
            ' Persona Natural ó (2) Persona Jurídica. Si consignó la opción'
            ' (2) no llenar los items 48 al 50 ni los items 53 al 57.')),
    ('48', ('Tipo de documento la persona a favor de quien se realiza la '
            'operación: Consignar el código de acuerdo a la Tabla N° 1')),
    ('49', ('Número de documento de la persona a favor de quien se realiza'
            ' la operación')),
    ('50', ('País de emisión del documento de la persona a favor de quien '
            'se realiza la operación, en caso sea un documento emitido en '
            'el extranjero.')),
    ('51', ('Número de RUC de la persona a favor de quien se realiza la'
            ' operación.')),
    ('52', ('Apellido paterno o razón social (persona jurídica) de la '
            'persona a favor de quien se realiza la operación.')),
    ('53', ('Apellido materno de la persona a favor de quien se realiza'
            ' la operación')),
    ('54', ('Nombres de la persona a favor de quien se realiza la '
            'operación')),
    ('55', ('Nacionalidad de la persona a favor de quien se realiza la'
            ' operación.')),
    ('56', ('Ocupación, oficio o profesión de la persona a favor de quien'
            ' se realiza la operación (persona natural): consignar los '
            'códigos de acuerdo a la Tabla N° 2.')),
    ('57', ('Descripción de la ocupación, oficio o profesión de la '
            'persona a favor de quien se realiza la operación en caso '
            'en el ítem anterior se haya consignado la opción otros.')),
    ('58', ('Actividad económica de la persona a favor de quien se realiza'
            ' la operación (persona jurídica u otras formas de organización'
            ' o asociación que la Ley establece): Consignar la actividad'
            ' principal')),
    ('59', ('Código CIIU de la ocupación de la persona a favor de quien '
            'se realiza la operación')),
    ('60', ('Cargo de la persona a favor de quien se realiza la operación'
            ' (si aplica): consignar el código que corresponda de acuerdo'
            ' a la Tabla N° 3.')),
    ('61', ('Nombre y número de la vía de la dirección de la persona a '
            'favor de quien se realiza la operación')),
    ('62', ('Código UBIGEO del departamento, provincia y distrito de la'
            ' dirección de la persona a favor de quien se realiza la'
            ' operación: de acuerdo a la codificación vigente y publicada'
            ' por el INEI.')),
    ('63', ('Teléfono de la persona a favor de quien se realiza la '
            'operación.'))
)

third = (
    ('64', 'Tipo de persona en cuya cuenta se realiza la operación: (1)'
        ' Persona Natural ó (2) Persona Jurídica. Si consignó la opción'
        ' (2) no llenar los items 65 al 66 ni los items 68 al 69'),
    ('65', 'Tipo de documento de la persona en cuya cuenta se realiza la'
        ' operación: Consignar el código de acuerdo a la Tabla N° 1.'),
    ('66', 'Número de documento de la persona en cuya cuenta se realiza la'
        ' operación'),
    ('67', 'Apellido paterno o razón social (persona jurídica) de la persona'
        ' en cuya cuenta se realiza la operación'),
    ('68', 'Apellido materno de la persona en cuya cuenta se realiza la'
        ' operación'),
    ('69', 'Nombres de la persona en cuya cuenta se realiza la operación'),
    ('70', 'La persona a favor de quien se realiza la operación es: (1)'
        ' Importador (ingreso de mercancía); (2) Destinatario del'
        ' embarque (salida de mercancía); (3) proveedor del extranjero'
        ' (ingreso de mercancía); (4) Exportador (salida de mercancía).')
)

operation = (
    ('71', ('Tipo de fondos con que se realizó la operación: consignar'
            ' el código de acuerdo a la Tabla N° 5.')),
    ('72', ('Tipo de operación: consignar el código de acuerdo a la '
            'Tabla N° 6: Tipos de Operación')),
    ('73', ('Descripción del tipo de operación en caso según la tabla'
            ' de operaciones se haya consignado el código de "Otros"')),
    ('74', ('Descripción de las mercancías involucradas en la operación')),
    ('75', ('Número de DAM')),
    ('76', ('Fecha de numeración de la DAM.')),
    ('77', ('Origen de los fondos involucrados en la operación.')),
    ('78', ('Moneda en que se realizo la operacion(Segun Codificacion'
            ' ISO-4217)')),
    ('79', ('Descripcion del tipo de moneda en caso sea "otra"')),
    ('80', ('Monto de la operación: Consignar el valor de la mercancía '
            'correspondiente a la operación de comercio exterior que se '
            'haya realizado. Los montos deberán estar expresados en nuevos'
            ' soles con céntimos. Para aquellas operaciones realizadas con'
            ' alguna moneda extranjera diferente a la indicada, se deberán'
            ' convertir a dólares, según el tipo de cambio que la entidad'
            ' tenga vigente el día que se realizó la operación')),
    ('81', ('Tipo de cambio: consignar el tipo de cambio respecto a la '
            'moneda nacional, en los casos en los que la operación haya'
            ' sido registrada en moneda diferente a soles, dólares o '
            'euros. El tipo de cambio será el que la entidad tenga '
            'vigente el día que se realizó la operación.')),
    ('82', ('Código de país de origen: para las operaciones relacionadas '
            'con importación de bienes, para lo cual deben tomar la '
            'codificación publicada por la SBS.')),
    ('83', ('Código de país de destino: para las operaciones relacionadas'
            ' con exportación de bienes, para lo cual deben tomar la '
            'codificación publicada por la SBS.')),
)

functions = {
    'declarant': (
        lambda d: d.represents_to,
        lambda d: d.residence_status,
        lambda d: (d.document_type).upper(),
        lambda d: d.document_number,
        lambda d: d.issuance_country,
        lambda d: d.father_name,
        lambda d: d.mother_name,
        lambda d: d.name,
        lambda d: d.nationality,
        lambda d: d.activity,
        lambda d: 'No aplica',
        lambda d: d.ciiu.name if d.ciiu else d.ciiu,
        lambda d: d.position,
        lambda d: d.address,
        lambda d: ('%s %s' % (d.ubigeo.code, d.ubigeo.name)
                   if d.ubigeo else d.ubigeo),
        lambda d: d.phone
    ),
    'customer': (
        lambda c: c.link_type,
        lambda c: c.represents_to,
        lambda c: c.condition,
        lambda c: ('Persona Jurídica'
                   if c.document_type == 'ruc'
                   else 'Persona Natural'),
        lambda c: ('No aplica'
                   if c.document_type == 'ruc'
                   else (c.document_type).upper()),
        lambda c: ('No aplica'
                   if c.document_type == 'ruc'
                   else c.document_number),
        lambda c: ('No aplica'
                   if c.document_type == 'ruc'
                   else c.issuance_country),
        lambda c: (c.document_number
                   if c.document_type == 'ruc'
                   else c.ruc),
        lambda c: (c.name
                   if c.document_type == 'ruc'
                   else c.father_name),
        lambda c: ('No aplica'
                   if c.document_type == 'ruc'
                   else c.mother_name),
        lambda c: ('No aplica'
                   if c.document_type == 'ruc'
                   else c.name),
        lambda c: ('No aplica'
                   if c.document_type == 'ruc'
                   else c.nationality),
        lambda c: ('No aplica'
                   if c.document_type == 'ruc'
                   else c.activity),
        lambda c: 'No aplica'
        lambda c: (c.activity
                   if c.document_type == 'ruc'
                   else 'No aplica'),
        lambda c: (c.ciiu.name
                   if c.ciiu? else ''),
        lambda c: (c.employment if c.employment else 'No aplica'),
        lambda c: c.address,
        lambda c: ('%s %s' % (c.ubigeo.code, c.ubigeo.name)
                   if c.ubigeo? else '')
        lambda c: c.phone,

    ),
    'stakeholder': (
        lambda s:  s.link_type,
        lambda s: 'No aplica',
        lambda s: 'No aplica',
        lambda s: ('Persona Jurídica'
                   if s.document_type == 'ruc' else 'Persona Natural'),
        lambda s: 'No aplica',
        lambda s: 'No aplica',
        lambda s: 'No aplica',
        lambda s: 'No aplica',
        lambda s: s.name if s.document_type == 'ruc' else s.father_name,
        lambda s: 'No aplica' if s.document_type == 'ruc' else s.mother_name,
        lambda s: 'No aplica' if s.document_type == 'ruc' else s.name,
        lambda s: 'No aplica',
        lambda s: 'No aplica',
        lambda s: 'No aplica',
        lambda s: 'No aplica',
        lambda s: 'No aplica',
        lambda s: 'No aplica',
        lambda s: s.address,
        lambda s: 'No aplica',
        lambda s: 'No aplica'
    ),
    'third': (
        lambda t: ('No aplica' if not t.document_type
                   else 'Persona Jurídica'
                   if t.document_type == 'ruc' else 'Persona Natural'),
        lambda t: ('No aplica' if not t.document_type
                   else 'No aplica' if t.document_type == 'ruc'
                   else (t.document_type).upper()),
        lambda t: ('No aplica' if not t.document_type
                   else 'No aplica' if t.document_type == 'ruc'
                   else t.document_number),
        lambda t: ('No aplica' if not t.document_type
                   else t.name if t.document_type == 'ruc'
                   else t.father_name),
        lambda t: ('No aplica' if not t.document_type
                   else 'No aplica' if t.document_type == 'ruc'
                   else t.mother_name),
        lambda t: ('No aplica' if not t.document_type
                   else 'No aplica' t.document_type == 'ruc'
                   else t.name)
        lambda t: t.third_ok if t.document_type else 'No aplica'
    ),
    'operation': (
        lambda d: d.declaration.customer.money_source_type,
        lambda d: d.regime.code,
        lambda d: 'No aplica',
        lambda d: d.description,
        lambda d: d.dam,
        lambda d: d.numeration_date,
        lambda d: d.declaration.customer.money_source,
        lambda d: 'USD',
        lambda d: 'No aplica',
        lambda d: d.amount_soles,
        lambda d: d.exchange_rate,
        lambda d: d.stakeholders[0].country if not d.is_out else 'No aplica',
        lambda d: d.stakeholders[0].country if d.is_out else 'No aplica'
    )
}


# vim: et:ts=4:sw=4
