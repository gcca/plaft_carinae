/** @module modules */

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

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

  _json-setter: (_dto) -> @el._fromJSON _dto

  set-type: ->
    @_select._value = it

  on-customer-type-change: ~>
    @trigger (gz.Css \change), it._target._value

  /** @override */
  initialize: ->
    super!
    @_select = App.dom._new \select
      .._class = gz.Css \form-control
      ..html = "<option value='j'>Jurídico</option>
                <option value='n'>Natural</option>"
      ..css = 'width:48.5%'
      ..on-change @on-customer-type-change

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


/** @export */
module.exports = Customer


# vim: ts=2:sw=2:sts=2:et
