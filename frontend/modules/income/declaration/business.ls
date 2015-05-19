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
  _json-getter: ->
    r = @el._toJSON!
    shareholders = @shareholders-view._toJSON!
    if shareholders._length
      r.'shareholders' = shareholders
    r

  _json-setter: (_dto) ->
    super _dto
    if _dto.'shareholders'?
      @shareholders-view.load-from _dto.'shareholders'

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
      _type: FieldType.kHidden
      _options: <[ruc]>

    * _name: 'name'
      _label: 'a) Denominación o razón social'

    * _name: 'document_number'
      _label: 'b) N&ordm; RUC'

    * _name: 'social_object'
      _label: 'c) Objeto Social'

    * _name: 'activity'
      _label: 'Actividad económica principal'
      _tip: 'Actividad económica de la persona en cuyo nombre se realiza la
           \ operación.'

    * _name: 'shareholders'
      _label: 'd) Identificacion accionistas'
      _grid: _GRID._full
      _type: FieldType.kView
      _options: new Shareholders

    * _name: 'legal'
      _label: 'e) Identificacion RL'
      _tip: 'Representante legal de la empresa.'

    * _name: 'address'
      _label: 'f) Domicilio'

    * _name: 'fiscal_address'
      _label: 'g) Domicilio Fiscal'

    * _name: 'phone'
      _label: 'h) Telefono oficina'

    * _name: 'money_source_type'
      _label: 'i) El origen de los fondos'
      _type: FieldType.kComboBox
      _options:
        'No efectivo'
        'Efectivo'

    * _name: 'money_source'
      _label: 'Descripción del origen de los fondos'

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
