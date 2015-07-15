/** @module modules.income */


Customer = require './customer'

modal = App.widget.message-box

App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField

Shareholders = require './shareholders'

FormRatio = App.form-ratio

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
    if not @ratio?
      @ratio = new FormRatio do
        fields: _FIELD_BUSINESS
        el: @el
    _ratio =  @ratio._calculate r
    if _ratio isnt 0
      @_panel._header._get panelgroup.ControlBar ._set-bar _ratio

    r

  _json-setter: (_dto) ->
    @shareholders-view.shareholders._length = 0
    super _dto
    # Progress Bar
    @ratio = new FormRatio do
      fields: _FIELD_BUSINESS
      el: @el
    _ratio =  @ratio._calculate _dto

    if _ratio isnt 0
      @_panel._header._get panelgroup.ControlBar ._set-bar _ratio

    @el.query '[name=document_type]'
      .._value = 'ruc'
    if _dto.'shareholders'?
      @shareholders-view.load-from _dto.'shareholders'

  /** @private */
  on-is_obligated-change: ~>
    officer = @form-builder._elements.'has_officer'
    officer._radios
      _officer-yes = .._yes
      _officer-no = .._no
    chk-officer = officer._checkbox
    is_obligated = @form-builder._elements.'is_obligated'._radios._no
    if is_obligated._checked
      _officer-yes._disabled = on
      _officer-yes._checked = off
      _officer-no._checked = on
      chk-officer._checked = off
    else
      _officer-yes._disabled = off
      _officer-no._checked = off

  /** @protected */
  set-default-type: -> @set-type 'j'

  template-table: ->
    _code = App.lists.activity-business._code
    _sector = App.lists.activity-business._sector
    _activity = App.lists.activity-business._display
    _tbody = ["<tr><td>#{_code[i]}</td>
               <td>#{_sector[i]}</td>
               <td>#{_activity[i]}</td></tr>" for i from 0 to _code._length-1].join ''
    tb = App.dom._new \table
    tb._class = "#{gz.Css \table}
               \ #{gz.Css \table-hover}"
    tb.html = "<thead>
                <tr>
                  <th><strong>Cod.</strong></th>
                  <th><strong>Sector</strong></th>
                  <th><strong>Actividad Económica</strong></th>
                </tr>
              </thead>
              <tbody>
                  #{_tbody}
              </tbody>"
    tb

  /** @override */
  render: ->
    @form-builder = new App.builder.Form @el, _FIELD_BUSINESS
      @shareholders-view = .._elements.'shareholders'._view

      .._elements.'is_obligated'._element
        ..on-change @on-is_obligated-change

      .._elements.'activity'._element
        ..on-key-up (evt) ~>
            if evt.key-code is 77 and evt.ctrl-key   # [ctrl+M]
              mdl = modal.Modal._new do
                  _title: 'Tabla de actividad económica.'
                  _body: @template-table!
              mdl._show!

      ..render!

    super!

  /** @private */ shareholders-view: null

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  ratio: null

  /** FIELD */
  _FIELD_BUSINESS =
    * _name: 'name'
      _label: 'a) Denominación o razón social'

    * _name: 'document_type'
      _type: FieldType.kHidden
      _options: <[ruc]>

    * _name: 'document_number'
      _label: 'b) N&ordm; RUC'

    * _name: 'social_object'
      _label: 'c) Objeto Social'

    * _name: 'activity'
      _label: 'Actividad económica principal'
      _tip: 'Actividad económica de la persona en cuyo nombre se realiza la
           \ operación. ([ctrl+M] para ver la tabla de actividad económica)'

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
      _label: 'i) Tipo de Fondos'
      _type: FieldType.kComboBox
      _options:
        'No efectivo'
        'Efectivo'

    * _name: 'money_source'
      _label: 'Origen de los fondos'

    * _name: 'is_obligated'
      _label: 'j) Si es Sujeto obligado'
      _type: FieldType.kYesNo

    * _name: 'has_officer'
      _label: 'Oficial cumplimiento'
      _type: FieldType.kYesNo

    * _name: 'reference'
      _label: 'Ref. Cliente'
      _grid: _GRID._inline


/** @export */
module.exports = Business


# vim: ts=2:sw=2:sts=2:et
