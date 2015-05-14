/** @module modules.income */


Customer = require './customer'

App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField

Shareholders = require './shareholders'

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair


class Business extends Customer

  /** @override */
  _tagName: \form

  /** @override */
  _toJSON: ->
    r = @el._toJSON!
    shareholders = @shareholders-view._toJSON!
    if shareholders._length
      r.'shareholders' = shareholders
    r

  /** @private */
  on-is_obligated-change: ~>
    @form-builder._elements'has_officer'._element
      _officer-yes = ..query '[value=Sí]'
      _officer-no = ..query '[value=No]'
    is_obligated = @el.query('[name=is_obligated]:checked').value
    if is_obligated === 'No'
      _officer-yes._disabled = on
      _officer-no._checked = on
    else
      _officer-yes._disabled = off

  /** @override */
  render: ->
    @form-builder = new App.builder.Form @el, _FIELD_BUSINESS
      @shareholders-view = .._elements.'shareholders'._view
      ..render!

      .._elements.'is_obligated'._element
        ..on-change @on-is_obligated-change
    super!

  /** @private */ shareholders-view: null

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

  /** FIELD */
  _FIELD_BUSINESS =
    * _name: 'document_type'
      _label: 'b) Tipo documento'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'name'
      _label: 'a) Denominación o razón social'

    * _name: 'document_number'
      _label: 'b) N&ordm; RUC'

    * _name: 'legal_type'
      _label: 'Representado Legal'
      _type: FieldType.kComboBox
      _options:
        'RL'
        'Apoderado'
        'Mandatario'
        'El mismo'

    * _name: 'condition'
      _label: 'Condición'
      _type: FieldType.kComboBox
      _options:
        'Residente'
        'No residente'

    * _name: 'social_object'
      _label: 'c) Objeto Social'

    * _name: 'activity'
      _label: 'Actividad economica principal'

    * _name: 'shareholders'
      _label: 'd) Identificacion accionistas'
      _grid: _GRID._full
      _type: FieldType.kView
      _options: new Shareholders

    * _name: 'legal'
      _label: 'e) Identificacion RL'

    * _name: 'address'
      _label: 'f) Domicilio'

    * _name: 'fiscal_address'
      _label: 'g) Domicilio Fiscal'

    * _name: 'phone'
      _label: 'h) Telefono oficina'

    * _name: 'money_source'
      _label: 'i) El origen de los fondos'
      _type: FieldType.kComboBox
      _options: App.lists.money-source._display

    * _name: 'ciiu'
      _label: 'Código CIIU de ocupacion'
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code : App.lists.ciiu._code
                   _name : App.lists.ciiu._display
                   _field : 'ciiu'

    * _name: 'ubigeo'
      _label: 'Código Ubigeo'
      _grid: _GRID._full
      _type: FieldType.kView
      _options : new CodeNameField do
                   _code: App.lists.ubigeo._pool._code
                   _name: App.lists.ubigeo._pool._display
                   _max-length: 15
                   _field: 'ubigeo'


    * _name: 'is_obligated'
      _label: 'j) Si es Sujeto obligado'
      _type: FieldType.kRadioGroup
      _options: <[Si No]>

    * _name: 'has_officer'
      _label: 'Oficial cumplimiento'
      _type: FieldType.kRadioGroup
      _options: <[Sí No]>

    * _name: 'reference'
      _label: 'Ref. Cliente'
      _grid: _GRID._inline


/** @export */
module.exports = Business


# vim: ts=2:sw=2:sts=2:et
