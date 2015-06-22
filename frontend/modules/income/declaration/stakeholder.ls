/** @module modules.income */

CodeNameField = App.widget.codename.CodeNameField
FieldType = App.builtins.Types.Field


class Stakeholder extends App.View
  App.mixin.JSONAccessor ::

  /** @override */
  _tagName: \form

  _json-getter: -> @el._toJSON!

  _json-setter: -> @el._fromJSON it

  display-legal: ->
    if it  # ingreso
      $ @_legal-field ._hide!
    else  # salida
      $ @_legal-field ._show!

  /** @override */
  initialize: ->
    super!

    App.builder.Form._new @el, _FIELDS
      ..render!

      @_legal-field = .._elements.'legal_type'._field

      .._free!

  /** @private */ _legal-field: null

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID

  _FIELDS =
    * _name: 'legal_type'
      _label: 'Representado Legal'
      _tip: 'La persona en cuyo nombre se realiza la operación ha sido
            \ representado por:'
      _type: FieldType.kComboBox
      _options:
        'RL'
        'Apoderado'
        'Mandatario'
        'El mismo'

    * _name: 'condition'
      _label: 'Condición'
      _tip: 'Condición de residencia de la persona en cuyo nombre se realiza
            \ la operación'
      _type: FieldType.kComboBox
      _options:
        'Residente'
        'No residente'

    * _name: 'ciiu'
      _label: 'Código CIIU de ocupacion'
      _tip: 'Código CIIU de la ocupación de la persona en cuyo nombre se
            \ realiza la operación([ctrl+M] para ver la tabla completa)'
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code : App.lists.ciiu._code
                   _name : App.lists.ciiu._display
                   _field : 'ciiu'

    * _name: 'ubigeo'
      _label: 'Código Ubigeo'
      _tip: 'Código UBIGEO del Departamento, provincia y distrito de la
            \ dirección de la persona en cuyo nombre se realiza la
            \ operación: de acuerdo a la codificación vigente y
            \ publicada por el INEI.([ctrl+M] para ver la tabla completa)'
      _grid: _GRID._full
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code: App.lists.ubigeo._pool._code
                   _name: App.lists.ubigeo._pool._display
                   _max-length: 15
                   _field: 'ubigeo'


/** @export */
module.exports = Stakeholder


# vim: ts=2:sw=2:sts=2:et
