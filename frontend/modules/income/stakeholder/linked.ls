/** @module modules */

widget = App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

BodyStakeholder = require './stakeholder'

/**
 * Linked
 * -----------
 * @class Linked
 * @extends View
 */
class FormLinked extends BodyStakeholder

  /** @override */
  render: ->
    ret = super!
    App.builder.Form._new @el, _FIELD_HEAD
      .._elements['customer_type']._field
        ._class +=" #{gz.Css \bg-warning}
                  \ #{gz.Css \has-warning}"
      ..render!
      .._free!
    @$el._append "<div></div>"
    @render-skateholder @_FIELD_PERSON, @@Type.kPerson
    @_panel.on (gz.Css \load-body), (_dto) ~>
      @_json = _dto
    ret

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

  /** FIELD */
  _FIELD_HEAD =
    * _name: 'linked_type'
      _label: 'Tipo de vinculación'
      _type: FieldType.kComboBox
      _options: <[Proveedor]>

    * _name: 'customer_type'
      _label: 'Tipo Persona'
      _type: FieldType.kComboBox
      _options:
        'Natural'
        'Jurídica'

  /** FIELD */
  _FIELD_PERSON :
    * _name: 'father_name'
      _label: 'Apellido paterno'

    * _name: 'mother_name'
      _label: 'Apellido materno'

    * _name: 'name'
      _label: 'Nombre completo'

    * _name: 'country'
      _label: 'País de emisión del documento'

    * _name: 'address'
      _label: 'Nombre y N° de la vía dirección'

    * _name: 'phone'
      _label: 'Teléfono de la persona'

    * _name: 'document_type'
      _type: FieldType.kHidden
      _options: <[dni]>

  /** FIELD */
  _FIELD_BUSINESS :
    * _name: 'name'
      _label: 'Razon social'

    * _name: 'social_object'
      _label: 'Objeto social'

    * _name: 'address'
      _label: 'Nombre y N° via direccion'

    * _name: 'phone'
      _label: 'Teléfono de la persona en cuyo nombre'

    * _name: 'document_type'
      _type: FieldType.kHidden
      _options: <[ruc]>

/** @export */
module.exports = FormLinked


# vim: ts=2:sw=2:sts=2:et
