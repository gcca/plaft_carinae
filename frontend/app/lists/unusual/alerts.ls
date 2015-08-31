/** @module app.lists */

exports._display =
  'Código de la señal de alerta'
  'Descripción de la señal de alerta'
  'Fuente de la señal de alerta: Sistema de Monitoreo (1), Área Comercial (2), Análisis del SO (3), Medio Periodístico (4) y Otras fuentes (5).'
  'En caso en el item 46 se haya consignado la opción 5 describir la fuente'

exports._code =
  '44'
  '45'
  '46'
  '47'

exports._method =
  (a) -> a.'info'.'section'+a.'info'.'code'
  (a) -> a.'info'.'description'
  (a) -> a.'source'
  (a) -> if a.'source' is 'Otras Fuentes' then a.'description_source' else 'No aplica'

# vim: ts=2:sw=2:sts=2:et
