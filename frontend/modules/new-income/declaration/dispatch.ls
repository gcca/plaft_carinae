/** @module modules */

widget = App.widget.codename
  CodeNameField = ..CodeNameField

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

panelgroup = App.widget.panelgroup


/**
 * Dispatch
 * ----------
 *
 * @class Dispatch
 * @extends View
 */
class DispatchBody extends panelgroup.FormBody


  _json-setter: (_dto) ->
    if _dto.'regime'?
      @_display = _dto.'regime'.'name'
    super _dto

  _get-type: ->
    if @_display?
      _k = App.lists.regime._display._index @_display
      return App.lists.regime._sbs[_k]


  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELD_DISPATCH
      ..render!
      @_typeahead = .._elements.'regime'._view._typeahead
      .._free!

    @_typeahead.on-selected (_, _obj) ~>
      _display = _obj.'_display'
      _k = App.lists.regime._display._index _display
      @trigger (gz.Css \code-regime), App.lists.regime._sbs[_k]

    super!

  _FIELD_DISPATCH=
      * _name: 'reference'
        _label: 'Ref. cliente'

      * _name: 'jurisdiction'
        _label: 'Aduana despacho/ Juridiccion'
        _tip: 'JURIDICCION'
        _type: FieldType.kView
        _options : new CodeNameField do
                     _code : App.lists.jurisdiction._code
                     _name : App.lists.jurisdiction._display
                     _field : 'jurisdiction'

      * _name: 'order'
        _label: 'N&ordm; Orden despacho'
        _tip: 'ORDEN DE DESPACHO'

      * _name: 'income_date'
        _label: 'Fecha ingreso orden de despacho'
        _placeholder: 'dd/mm/YYYY'

      * _name: 'regime'
        _label: 'Regimen Aduanero'
        _type: FieldType.kView
        _options : new CodeNameField do
                     _code : App.lists.regime._code
                     _name : App.lists.regime._display
                     _field : 'regime'

      * _name: 'description'
        _label: 'Descripcion mercancia'

  _display: null

/** @export */
module.exports = DispatchBody


# vim: ts=2:sw=2:sts=2:et
