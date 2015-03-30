/** @module modules */

customer = require './customer'
  Identification = ..Identification
widget = App.widget.codename
  CodeNameField = ..CodeNameField

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

/**
 * Dispatch
 * ----------
 * TODO
 *
 * @class Dispatch
 * @extends View
 */
class Dispatch extends App.View

  /** @override */
  _tagName: \form

  /** @override */
  initialize: ({@dispatch}) -> super!

  /** @override */
  render: ->
    @el.html = ""

    _FIELD_DISPATCH=
      * _name: 'reference'
        _label: 'Ref. cliente'
        _tip: "REFERENCIAREFERENCIAREFERENCIAREFERENCIAREFERENCIAREFERENCIA \
              REFERENCIAREFERENCIAREFERENCIAREFERENCIAREFERENCIA"

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

    App.builder.Form._new @el, _FIELD_DISPATCH
      ..render!
      .._free!

    @el._fromJSON @dispatch

    super!


/** @export */
module.exports = Dispatch


# vim: ts=2:sw=2:sts=2:et
