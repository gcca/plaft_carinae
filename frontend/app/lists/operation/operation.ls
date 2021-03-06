/** @module app.lists */

exports._display =
  'Tipo de fondos con que se realizó la operación: consignar el código de acuerdo a la Tabla N° 5.'
  'Tipo de operación: consignar el código de acuerdo a la Tabla N° 6: Tipos de Operación'
  'Descripción del tipo de operación en caso según la tabla de operaciones se haya consignado el código de "Otros"'
  'Descripción de las mercancías involucradas en la operación'
  'Número de DAM'
  'Fecha de numeración de la DAM.'
  'Origen de los fondos involucrados en la operación.'
  'Moneda en que se realizo la operacion(Segun Codificacion ISO-4217)'
  'Descripcion del tipo de moneda en caso sea "otra"'
  'Monto de la operación: Consignar el valor de la mercancía correspondiente a la operación de comercio exterior que se haya realizado. Los montos deberán estar expresados en nuevos soles con céntimos. Para aquellas operaciones realizadas con alguna moneda extranjera diferente a la indicada, se deberán convertir a dólares, según el tipo de cambio que la entidad tenga vigente el día que se realizó la operación'
  'Tipo de cambio: consignar el tipo de cambio respecto a la moneda nacional, en los casos en los que la operación haya sido registrada en moneda diferente a soles, dólares o euros. El tipo de cambio será el que la entidad tenga vigente el día que se realizó la operación.'
  'Código de país de origen: para las operaciones relacionadas con importación de bienes, para lo cual deben tomar la codificación publicada por la SBS.'
  'Código de país de destino: para las operaciones relacionadas con exportación de bienes, para lo cual deben tomar la codificación publicada por la SBS.'

exports._code =
  '71'
  '72'
  '73'
  '74'
  '75'
  '76'
  '77'
  '78'
  '79'
  '80'
  '81'
  '82'
  '83'

exports._method =
  (d) -> d.'declaration'.'customer'.'money_source_type'
  (d) -> d.'regime'.'code'
  -> 'No aplica'
  (d) -> d.'description'
  (d) -> d.'dam'
  (d) -> d.'numeration_date'
  (d) -> d.'declaration'.'customer'.'money_source'
  -> 'USD'
  -> 'No aplica'
  (d) -> (d.'exchange_rate' * d.'amount').to-fixed 2
  (d) -> d.'exchange_rate'
  (d) -> if not d.'is_out' then d.'stakeholders'.'0'.'country' else 'No aplica'
  (d) -> if d.'is_out' then d.'stakeholders'.'0'.'country' else 'No aplica'

# vim: ts=2:sw=2:sts=2:et
