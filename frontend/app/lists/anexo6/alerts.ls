/** @module app.lists */

exports._display =[
  'SEÑALES DE ALERTA IDENTIFICADAS (Se debe consignar estos datos por cada señal de alerta)'
  [['44', 'Código de la señal de alerta', (a) -> a.'code']
  ['45', 'Descripción de la señal de alerta', (a) -> a.'description']
  ['46', 'Fuente de la señal de alerta: Sistema de Monitoreo (1), Área Comercial (2), Análisis del SO (3), Medio Periodístico (4) y Otras fuentes (5).', (s) -> 'FALTA']
  ['47', 'En caso en el item 46 se haya consignado la opción 5 describir la fuente', (s) -> 'FALTA']]
]
exports._code =
  '44'
  '45'
  '46'
  '47'

# vim: ts=2:sw=2:sts=2:et
