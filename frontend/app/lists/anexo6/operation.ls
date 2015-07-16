/** @module app.lists */

exports._display =[
  'DATOS RELACIONADOS A LA DESCRIPCIÓN DE LA OPERACIÓN INUSUAL'
  [['29', 'Tipo de fondos con que se realizó la operación: consignar el código de acuerdo a la Tabla N° 4.', (d) -> d.'declaration'.'customer'.'money_source_type']
  ['30', 'Tipo de operación: consignar el código de acuerdo a la Tabla N° 5: Tipos de Operación', (d) -> d.'regime'.'name']
  ['31', 'Descripción del tipo de operación en caso según la tabla de operaciones se haya consignado el código de "Otros"', -> 'No aplica' ]
  ['32', 'Descripción de las mercancías involucradas en la operación', (d) -> d.'description']
  ['33', 'Origen de los fondos involucrados en la operación.', (d) -> d.'declaration'.'customer'.'money_source']
  ['34', 'Moneda en que se realizo la operacion: S=Nuevos Soles, USD =Dólares Americanos,E= Euros y O= Otra(Detallar en item siguiente)', -> 'USD']
  ['35', 'Descripción del tipo de moneda en caso sea "Otra"', -> 'No aplica']
  ['36', 'Monto de la operación: Consignar el valor de la mercancía correspondiente a la operación de comercio exterior que se haya realizado. Los montos deberán estar expresados en nuevos soles con céntimos. Para aquellas operaciones realizadas con alguna moneda extranjera diferente a la indicada, se deberán convertir a dólares, según el tipo de cambio que la entidad tenga vigente el día que se realizó la operación', (d) -> (parseFloat d.'amount'*d.'exchange_rate').to-fixed 2]
  ['37', 'Tipo de cambio: consignar el tipo de cambio respecto a la moneda nacional, en los casos en los que la operación haya sido registrada en moneda diferente a soles, dólares o euros. El tipo de cambio será el que la entidad tenga vigente el día que se realizó la operación.', (d) -> d.'exchange_rate']
  ['38', 'Código de país de origen: para las operaciones relacionadas con importación de bienes, para lo cual deben tomar la codificación publicada por la SBS.', (d) -> d.'stakeholders'.'0'.'country']
  ['39', 'Código de país de destino: para las operaciones relacionadas con exportación de bienes, para lo cual deben tomar la codificación publicada por la SBS.', (d) -> d.'stakeholders'.'0'.'country']
  ['40', 'Descripción de la operación(Señale los argumentos que lo llevaron a calificar como inusual la operación).', -> 'FALTA COLOCAR']
  ['41', 'La operación ha sido calificada como sospechosa (1)Si, (2)No', -> 'FALTA COLOCAR']
  ['42', 'En caso en el item 41 haya consignado la opción (1) indicar el número de ROS con el que se remitió a la UIF.', -> 'FALTA COLOCAR']
  ['43', 'En caso en el item 41 haya consignado la opción (2) describir los argumentos por los cuales esta operación no fue calificada como sospechosa.', -> 'FALTA COLOCAR']]
]
exports._code =
  '29'
  '30'
  '31'
  '32'
  '33'
  '34'
  '35'
  '36'
  '37'
  '38'
  '39'
  '40'
  '41'
  '42'
  '43'

# vim: ts=2:sw=2:sts=2:et
