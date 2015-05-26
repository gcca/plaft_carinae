/** @module modules */

CodeNameField = App.widget.codename.CodeNameField
FieldType = App.builtins.Types.Field

panelgroup = App.widget.panelgroup


class Customer extends App.View
  App.mixin.JSONAccessor ::

  /** @override */
  _tagName: \form

  /**
   * Customer form to JSON.
   * @return Object
   * @protected
   */
  _json-getter: -> @el._toJSON!

  _json-setter: (_dto) ->
    @el.query '[name=document_type]'
      .._value = 'dni'
    @el._fromJSON _dto

  set-type: ->
    @_select._value = it

  /** @protected */
  set-default-type: ->
    throw 'BRUTAL-ERROR'

  on-customer-type-change: ~>
    @trigger (gz.Css \change), it._target._value

  /** @override */
  initialize: ->
    super!

    @_select = App.dom._new \select
      .._class = gz.Css \form-control
      ..html = "<option value='j'>Jurídica</option>
                <option value='n'}>Natural</option>"
      ..css = 'width:48.5%'
      ..on-change @on-customer-type-change

    @set-default-type!

    _div = App.dom._new \div
      .._class = "#{gz.Css \form-group}
                \ #{gz.Css \col-md-12}"
      ..html = '<label>Tipo de persona</label>'
      .._append @_select

    @el._append _div

  /**
   * See Business and Person initialize and their events.
   * @see initialize
   * @private
   */ form-builder: null

  /** @private */ _select: null

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID

  /** @see Business, Person */
  COMMON-FIELDS:
    _legal-type:
      _name: 'legal_type'
      _label: 'Representado Legal'
      _type: FieldType.kComboBox
      _options:
        'RL'
        'Apoderado'
        'Mandatario'
        'El mismo'

    _condition:
      _name: 'condition'
      _label: 'Condición'
      _type: FieldType.kComboBox
      _options:
        'Residente'
        'No residente'

    _ciiu:
      _name: 'ciiu'
      _label: 'Código CIIU de ocupacion'
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code : App.lists.ciiu._code
                   _name : App.lists.ciiu._display
                   _field : 'ciiu'

    _ubigeo:
      _name: 'ubigeo'
      _label: 'Código Ubigeo'
      _grid: _GRID._full
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code: App.lists.ubigeo._pool._code
                   _name: App.lists.ubigeo._pool._display
                   _max-length: 15
                   _field: 'ubigeo'


/** @export */
module.exports = Customer


# vim: ts=2:sw=2:sts=2:et
