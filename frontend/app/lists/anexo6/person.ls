/** @module app.lists */

exports._display =[
  'DATOS DE IDENTIFICACIÓN DE LAS PERSONAS INVOLUCRADAS EN LAS OPERACIONES INUSUALES (consignar los datos consignados en esta sección por cada persona involucrada en la operación inusual)'
  [['6', 'La persona en cuyo nombre se realiza la operación es: (1) proveedor del extranjero (ingreso de mercancía), (2) Importador (ingreso de mercancía),ó Exportador (salida de mercancía) ó Destinatario del embarque (salida de mercancía).', (c) -> c.'link_type']
  ['7', 'Tipo de persona: (1) Persona Natural ó (2) Persona Jurídica. Si consignó la opción (2) no llenar los items 08 al 13 ni los items del 15 al 22.', (c) -> if c.'document_type' is 'ruc' then 'Persona Jurídica' else 'Persona Natural']
  ['8', 'Tipo de documento de identidad. Consignar el código de acuerdo a la Tabla N° 1.', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else (c.'document_type').to-upper-case!]
  ['9', 'Número de documento de identidad.', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'document_number']
  ['10', 'Condición de residencia: (1) Residente ó (2) No Residente.', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'condition']
  ['11', 'País de emisión del documento (en caso corresponda).', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'issuance_country']
  ['12', 'Persona es PEP: (1)Si ó (2)No.', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'is_pep']
  ['13', 'En caso en el item 12 haya consignado la opción (1), indicar el cargo público que desempeña.', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'employment']
  ['14', 'Apellido paterno o razón social (persona jurídica).', (c) -> if c.'document_type' is 'ruc' then c.'name' else c.'father_name']
  ['15', 'Apellido materno.', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'mother_name']
  ['16', 'Nombres.', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'name']
  ['17', 'Nacionalidad.', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'nationality']
  ['18', 'Fecha de Nacimiento (dd/mm/aaaa).', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'birthday']
  ['19', 'Ocupación, oficio o profesión (persona natural) : Consignar los códigos de acuerdo a la Tabla No 2.', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'activity']
  ['20', 'Descripción de la ocupación, oficio o profesión la opción otros.', -> 'No aplica']
  ['21', 'Empleador (En caso de ser dependiente).', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'employer']
  ['22', 'Ingresos promedios mensuales aproximados (En caso de ser dependiente).', (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'average_income']
  ['23', 'Objeto social de la persona jurídica(Consignar la actividad principal).', (c) -> if c.'document_type' is 'ruc' then c.'social_object' else 'No aplica']
  ['24', 'Cargo (si aplica): Consignar los códigos de acuerdo a la Tabla No 3.', -> 'No aplica']
  ['25', 'Nombre y número de la vía de la dirección.',(c) -> c.'address']
  ['26', 'Teléfono de la persona en cuyo nombre se realiza la operación.', (c) -> c.'phone']
  ['27', 'Condición en la que interviene en la operación inusual: (1) Involucrado ó (2) Vinculado', (c) -> c.'condition_intervene']
  ['28', 'Describir la condición en la que interviene en la operación inusual.', -> 'FALTA']]
]
exports._code =
  '6'
  '7'
  '8'
  '9'
  '10'
  '11'
  '12'
  '13'
  '14'
  '15'
  '16'
  '17'
  '18'
  '19'
  '20'
  '21'
  '22'
  '23'
  '24'
  '25'
  '26'
  '27'
  '28'

# vim: ts=2:sw=2:sts=2:et
