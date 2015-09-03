/** @module app.lists */

exports._display =
  'La persona en cuyo nombre se realiza la operación es: (1) proveedor del extranjero (ingreso de mercancía), (2) Importador (ingreso de mercancía),ó Exportador (salida de mercancía) ó Destinatario del embarque (salida de mercancía).'
  'Tipo de persona: (1) Persona Natural ó (2) Persona Jurídica. Si consignó la opción (2) no llenar los items 08 al 13 ni los items del 15 al 22.'
  'Tipo de documento de identidad. Consignar el código de acuerdo a la Tabla N° 1.'
  'Número de documento de identidad.'
  'Condición de residencia: (1) Residente ó (2) No Residente.'
  'País de emisión del documento (en caso corresponda).'
  'Persona es PEP: (1)Si ó (2)No.'
  'En caso en el item 12 haya consignado la opción (1), indicar el cargo público que desempeña.'
  'Apellido paterno o razón social (persona jurídica).'
  'Apellido materno.'
  'Nombres.'
  'Nacionalidad.'
  'Fecha de Nacimiento (dd/mm/aaaa).'
  'Ocupación, oficio o profesión (persona natural) : Consignar los códigos de acuerdo a la Tabla No 2.'
  'Descripción de la ocupación, oficio o profesión la opción otros.'
  'Empleador (En caso de ser dependiente).'
  'Ingresos promedios mensuales aproximados (En caso de ser dependiente).'
  'Objeto social de la persona jurídica(Consignar la actividad principal).'
  'Cargo (si aplica): Consignar los códigos de acuerdo a la Tabla No 3.'
  'Nombre y número de la vía de la dirección.'
  'Teléfono de la persona en cuyo nombre se realiza la operación.'
  'Condición en la que interviene en la operación inusual: (1) Involucrado ó (2) Vinculado'
  'Describir la condición en la que interviene en la operación inusual.'

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

exports._method =
  (c) -> c.'link_type'
  (c) -> if c.'document_type' is 'ruc' then 'Persona Jurídica' else 'Persona Natural'
  (c) -> if c.'document_type' is 'ruc' then 'No aplica' else (c.'document_type').to-upper-case!
  (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'document_number'
  (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'condition'
  (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'issuance_country'
  (c) ->
        if c.'document_type' is 'ruc'
          'No aplica'
        else
          if c.'is_pep' then 'Si' else 'No'
  (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'employment'
  (c) -> if c.'document_type' is 'ruc' then c.'name' else c.'father_name'
  (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'mother_name'
  (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'name'
  (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'nationality'
  (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'birthday'
  (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'activity'
  -> 'No aplica'
  (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'employer'
  (c) -> if c.'document_type' is 'ruc' then 'No aplica' else c.'average_income'
  (c) -> if c.'document_type' is 'ruc' then c.'social_object' else 'No aplica'
  -> 'No aplica'
  (c) -> c.'address'
  (c) -> c.'phone'
  (c) -> c.'unusual_condition'
  (c) -> c.'unusual_operation'

# vim: ts=2:sw=2:sts=2:et