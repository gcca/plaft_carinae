/** @module app.lists */


exports._display =
  'Importacion para el Consumo'
  'Reimportacion en el mismo Estado'
  'Exportacion Definitiva'
  'Exportacion Temporal para Reimportacion en el mismo Estado'
  'Exportacion Temporal para Perfeccionamiento Pasivo'
  'Admision temporal para Perfeccionamiento Activo'
  'Admision temporal para Reexportacion en el mismo Estado'
  'Drawback'
  'Reposicion de Mercancias con Franquicia Arancelaria'
  'Deposito Aduanero'
  'Reembarque'
  'Transito Aduanero'
  'Importacion Simplificada'
  'Exportacion Simplificada'
  'Material de Uso Aeronautico'
  'Destino Especial de Tienda Libre (DUTY FREE)'
  'Rancho de naves'
  'Material de Guerra'
  'Vehiculos para Turismo'
  'Material uso Aeronautico'
  'Ferias o Exposiciones Internacionales'
  ''

exports._code =
  '10'
  '36'
  '40'
  '51'
  '52'
  '21'
  '20'
  '41'
  '41'
  '70'
  '89'
  '80'
  '18'
  '48'
  '71'
  '72'
  ''
  ''
  ''
  ''
  '20'
  ''

exports._sbs =
  on # Entrada de mercaderia
  on # Entrada de mercaderia
  off # Salida de mercaderia
  off # Salida de mercaderia
  off # Salida de mercaderia
  off # Salida de mercaderia
  on # Entrada de mercaderia
  off # Salida de mercaderia
  off # Salida de mercaderia
  on # Entrada de mercaderia
  off # Salida de mercaderia
  on # Entrada de mercaderia
  on # Entrada de mercaderia
  off # Salida de mercaderia
  on # Entrada de mercaderia
  on # Entrada de mercaderia
  on # Entrada de mercaderia
  on # Entrada de mercaderia
  on # Entrada de mercaderia
  on # Entrada de mercaderia
  on # Entrada de mercaderia


# vim: ts=2:sw=2:sts=2:et
