/** @module modules */

Shareholders = require './shareholders'

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

/**
 * Business
 * ----------
 * TODO
 *
 * @class Business
 * @extends View
 */
class Business extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELD_BUSINESS
      ..render!
      .._free!

    super!

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

  /** FIELD */
  _FIELD_BUSINESS =
    * _name: 'customer_type'
      _label: 'Tipo Persona'
      _type: FieldType.kComboBox
      _grid: _GRID._inline
      _options: <[Juridico Natural]>

    * _name: 'client_type'
      _label: 'Tipo de cliente'
      _type: FieldType.kComboBox
      _options:
        'Importador frecuente'
        'Buen contribuyente'
        'OEA'
        'Otros'

    * _name: 'validity'
      _label: 'Vigencia'

    * _name: 'document[type]'
      _label: 'b) Tipo documento'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'social'
      _label: 'a) Razon Social'

    * _name: 'ruc'
      _label: 'b) RUC'

    * _name: 'social_object'
      _label: 'c) Objeto Social'

    * _name: 'activity'
      _label: 'c1) Actividad Economica'

    * _name: 'shareholders'
      _label: 'd) Identificacion accionistas'
      _grid: _GRID._flush-left
      _type: FieldType.kView
      _options: new Shareholders

    * _name: 'identification'
      _label: 'e) Identificacion RL'

    * _name: 'address'
      _label: 'f) Domicilio'

    * _name: 'fiscal_address'
      _label: 'g) Domicilio Fiscal'

    * _name: 'ubigeo'
      _label: 'Código Ubigeo'
      _grid: _GRID._flush-left

    * _name: 'phone'
      _label: 'h) Telefono'
      _grid: _GRID._inline

    * _name: 'is_obligated'
      _label: 'n) Si es Sujeto obligado'
      _type: FieldType.kRadioGroup
      _options: <[Si No]>

    * _name: 'has_officer'
      _label: 'Oficial cumplimiento'
      _type: FieldType.kRadioGroup
      _options: <[Sí No]>

    * _name: 'money_source'
      _label: 'm) El origen de los fondos'
      _type: FieldType.kComboBox
      _options: App.lists.money_source._display

    * _name: 'reference'
      _label: 'Ref. Cliente'

/** @export */
module.exports = Business


# vim: ts=2:sw=2:sts=2:et
