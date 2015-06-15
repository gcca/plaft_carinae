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
    _is-obligate = @form-builder._elements'is_obligated'._radios
    _has-officer = @form-builder._elements'has_officer'._radios

    if _dto.'is_obligated'?
      if _dto.'is_obligated'
        _is-obligate._yes._checked = true
      else
        _is-obligate._no._checked = true
    if _dto.'has_officer'?
      if _dto.'has_officer'
        _has-officer._yes._checked = true
      else
        _has-officer._no._checked = true

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
  /** @protected */ _panel: null

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID


/** @export */
module.exports = Customer


# vim: ts=2:sw=2:sts=2:et
