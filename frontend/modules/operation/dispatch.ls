/** @module modules */

customer = require './customer'
  Identification = ..Identification

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

  on-customer-change: ~>

  render: ->
    App.builder.Form._new @el, _FIELD_DISPATCH
      ..render!
      .._free!

    @el._append (new Identification).render!.el

    super!

  _FIELD_DISPATCH=
    * _name: 'reference'
      _label: 'Ref. cliente'

    * _name: 'jurisdiction'
      _label: 'Aduana despacho/ Juridiccion'

    * _name: 'order'
      _label: 'N&ordm; Orden despacho'

    * _name: 'income_date'
      _label: 'Fecha ingreso orden de despacho'
      _placeholder: 'dd/mm/YYYY'

    * _name: 'regime'
      _label: 'Regimen Aduanero'

    * _name: 'description'
      _label: 'Descripcion mercancia'


/** @export */
module.exports = Dispatch


# vim: ts=2:sw=2:sts=2:et
