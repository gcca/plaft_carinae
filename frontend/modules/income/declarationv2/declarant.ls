/** @module modules.income */

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair


/**
 * Declarant
 * ----------
 * @class Declarant
 * @extends View
 */
class Declarant extends App.View
  App.mixin.JSONAccessor ::

  /** @override */
  _tagName: \form

  /** @override */
  _className: gz.Css \col-md-12

  _json-getter: -> @el._toJSON!

  _json-setter: (_dto) -> @el._fromJSON _dto

  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELDS
      ..render!
      .._free!

    super!

  _GRID = App.builder.Form._GRID

  /** Field list for business form. (Array.<FieldOptions>) */
  _FIELDS =
    * _name: 'name'
      _label: 'Nombre'

    * _name: 'father_name'
      _label: 'Apellido Paterno'

    * _name: 'mother_name'
      _label: 'Apellido Materno'

    * _name: 'document_type'
      _label: 'Tipo de documento'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document_number'
      _label: 'Número de documento'

    * _label: 'Domicilio'
      _type: FieldType.kLabel
      _grid: _GRID._inline

    * _name: 'street'
      _label: 'Av./Calle/Jr./Psje./Prolongación'
      _type: FieldType.kComboBox
      _options: App.lists.ubigeo.street._display

    * _name: 'address'
      _label: 'Domicilio'

    * _name: 'flat'
      _label: 'Depto.'

    * _name: 'urbanization'
      _label: 'Urb./Complejo/AA.HH./Centro Poblado'
      _type: FieldType.kComboBox
      _options: App.lists.ubigeo.urbanization._display

    * _name: 'distrit'
      _label: 'Distrito'
      _type: FieldType.kComboBox
      _options: App.lists.ubigeo.distrit._display

    * _name: 'province'
      _label: 'Provincia'
      _type: FieldType.kComboBox
      _options: App.lists.ubigeo.province._display

    * _name: 'department'
      _label: 'Departamento'
      _type: FieldType.kComboBox
      _options: App.lists.ubigeo.department._display


/** @export */
module.exports = Declarant


# vim: ts=2:sw=2:sts=2:et
