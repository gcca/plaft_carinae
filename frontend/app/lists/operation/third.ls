/** @module app.lists */

exports._display =
  'Tipo de persona en cuya cuenta se realiza la operación: (1) Persona Natural ó (2) Persona Jurídica. Si consignó la opción (2) no llenar los items 65 al 66 ni los items 68 al 69'
  'Tipo de documento de la persona en cuya cuenta se realiza la operación: Consignar el código de acuerdo a la Tabla N° 1.'
  'Número de documento de la persona en cuya cuenta se realiza la operación'
  'Apellido paterno o razón social (persona jurídica) de la persona en cuya cuenta se realiza la operación'
  'Apellido materno de la persona en cuya cuenta se realiza la operación'
  'Nombres de la persona en cuya cuenta se realiza la operación'
  'La persona a favor de quien se realiza la operación es: (1) Importador (ingreso de mercancía); (2) Destinatario del embarque (salida de mercancía); (3) proveedor del extranjero (ingreso de mercancía); (4) Exportador (salida de mercancía).'

exports._code =
  '64'
  '65'
  '66'
  '67'
  '68'
  '69'
  '70'

exports._method =
  (t) ->
    if t.'document_type'?
      if t.'document_type' is \ruc
        'Persona Jurídica'
      else 'Persona Natural'
    else
      'No aplica'
  (t) ->
    if t.'document_type'?
      if t.'document_type' is \ruc
        'No aplica'
      else
        (t.'document_type').to-upper-case!
    else
      'No aplica'
  (t) ->
    if t.'document_type'?
      if t.'document_type' is \ruc
        t.'document_number'
      else 'No aplica'
    else
      'No aplica'
  (t) ->
    if t.'document_type'?
      if t.'document_type' is \ruc
        t.'name'
      else t.'father_name'
    else
      'No aplica'
  (t) ->
    if t.'document_type'?
      if t.'document_type' is \ruc
        'No aplica'
      else t.'mother_name'
    else
      'No aplica'
  (t) ->
    if t.'document_type'?
      if t.'document_type' is \ruc
        'No aplica'
      else t.'name'
    else
      'No aplica'
  (t) -> if t.'document_type'? then t.'third_ok' else 'No aplica'

# vim: ts=2:sw=2:sts=2:et
