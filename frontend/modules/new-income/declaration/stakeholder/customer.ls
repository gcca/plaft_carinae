/** @module modules */

widget = App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

BodyStakeholder = require './stakeholder'

/**
 * Customer
 * -----------
 * @class Customer
 * @extends View
 */
class FormCustomer extends BodyStakeholder

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
    ret

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

  /** FIELD */
  _FIELD_HEAD =
    * _name: '' # TODO
      _label: 'Tipo de vinculación'
      _type: FieldType.kComboBox
      _options: <[Exportador]>

    * _name: 'customer_type' # TODO
      _label: 'Tipo Persona'
      _type: FieldType.kComboBox
      _options:
        'Natural'
        'Jurídica'

    * _name: '' # TODO
      _label: 'La persona en cuyo nombre'
      _tip: 'La persona en cuyo nombre se realiza la operación'
      _type: FieldType.kComboBox
      _options:
        'Representante legal'
        'Apoderado'
        'Mandatario'
        'Él mismo'

    * _name: '' # TODO
      _label: 'Condición de residencia'
      _tip: "Condición de residencia de la persona en cuyo nombre se realiza
          \ la operación."
      _type: FieldType.kComboBox
      _options:
        'Residente'
        'No residente'

  /** FIELD */
  _FIELD_PERSON :
    * _name: '' # TODO
      _label: 'Tipo de documento de identidad'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: '' # TODO
      _label: 'Número de documento de identidad'

    * _name: '' # TODO
      _label: 'País de emisión del documento'

    * _name: 'father_name' # TODO
      _label: 'Apellido paterno'

    * _name: 'mother_name' # TODO
      _label: 'Apellido materno'

    * _name: 'name' # TODO
      _label: 'Nombres'

    * _name: '' # TODO
      _label: 'Nacionalidad'

    * _name: '' # TODO
      _label: 'Ocupación, oficio o profesión'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.activity._display
                   _field : 'pep_position'

    * _name: '' # TODO
      _label: 'Código CIIU de ocupacion'
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code : App.lists.ciiu._code
                   _name : App.lists.ciiu._display
                   _field : 'ciiu'

    * _name: '' # TODO
      _label: 'Cargo (si aplica)'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.office._display
                   _field : 'pep_position'

    * _name: '' # TODO
      _label: 'Nombre y N° de la vía dirección'

    * _name: '' # TODO
      _label: 'Teléfono de la persona operación'

    * _name: '' # TODO
      _label: 'Teléfono de la persona operación'

  /** FIELD */
  _FIELD_BUSINESS :
    * _name: '' # TODO
      _label: 'Numero de RUC'
      _tip: "Número de RUC de la persona en cuyo nombre se realiza
           \ la operación."

    * _name: 'name' # TODO
      _label: 'Razón social'
      _tip: "Razón social de la person en cuyo nombre se realiza
           \ la operación."

    * _name: '' # TODO
      _label: 'Actividad Ecónomica'
      _tip: "Actividad ecónomica de la persona en cuyo nombre se realiza
           \ la operación."

    * _name: '' # TODO
      _label: 'Nombre y N° via direccion'

    * _name: '' # TODO
      _label: 'Télefono de la persona'

    * _name: '' # TODO
      _type: FieldType.kHidden
      _options: <[ruc]>

/** @export */
module.exports = FormCustomer


# vim: ts=2:sw=2:sts=2:et
