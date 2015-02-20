/** @module modules */

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
  render: ->
    App.builder.Form._new @el, _FIELD_DISPATCH
      ..render!
      .._free!
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

    * _name: 'regime'
      _label: 'Regimen Aduanero'

    * _name: 'description'
      _label: 'Descripcion mercancia'

    * _name: 'third_identification'
      _label: 'Identificacion Tercero'
      _type: FieldType.kRadioGroup
      _options: <[Si No]>


/** @export */
module.exports = Dispatch


# vim: ts=2:sw=2:sts=2:et
