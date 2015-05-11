/** @module modules */

customer = require './customer'
  Identification = ..Identification

widget = App.widget.codename
  CodeNameField = ..CodeNameField

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

panelgroup = require '../../app/widgets/panelgroup'
/**
 * Dispatch
 * ----------
 *
 * @class Dispatch
 * @extends View
 */
class DispatchBody extends panelgroup.FormBody


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

/** @export */
module.exports = DispatchBody


# vim: ts=2:sw=2:sts=2:et
