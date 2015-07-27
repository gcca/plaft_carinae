/** @module modules.income */


Customer = require './customer'

modal = App.widget.message-box

App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField

FormRatio = App.form-ratio

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair


class Person extends Customer

  _json-getter: ->
    r = super!
    if not @ratio?
      @ratio = new FormRatio do
        fields: _FIELD_PERSON
        el: @el
    _ratio =  @ratio._calculate r
    if _ratio isnt 0
      @_panel._header._get panelgroup.ControlBar ._set-bar _ratio
    r

  _json-setter: (_dto) ->
    _is-pep = @form-builder._elements'is_pep'._radios
    employment = @form-builder._elements.'employment'._view._input
    if _dto.'is_pep'?
      if _dto.'is_pep'
        _is-pep._yes._checked = true
        employment._disabled = off
      else
        _is-pep._no._checked = true
        employment._disabled = on
    super _dto
    # Progress Bar
    @ratio = new FormRatio do
      fields: _FIELD_PERSON
      el: @el
    _ratio =  @ratio._calculate _dto

    if _ratio isnt 0
      @_panel._header._get panelgroup.ControlBar ._set-bar _ratio

  clean-text-partner: ~>
    @el.query('[name=partner]')._disabled = on
    @el.query('[name=partner]').value = ""

  on-civil_state-change: ~>
    _civil_type = @el.query('[name=civil_state]').selectedIndex
    switch _civil_type
      | 1, 4 => @el.query('[name=partner]')._disabled = off
      | otherwise => @clean-text-partner!

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

  on-is_pep-change: ~>
    employment = @form-builder._elements.'employment'._view._input
    is_pep = @form-builder._elements.'is_pep'._radios._no
    if is_pep._checked
      employment._value = ''
      employment._disabled = on
    else
      employment._value = ''
      employment._disabled = off


  /** @protected */
  set-default-type: -> @set-type 'n'

  /** @override */
  render: ->
    @form-builder = new App.builder.Form @el, _FIELD_PERSON

      .._elements'civil_state'._element
        ..on-change @on-civil_state-change

      .._elements.'is_obligated'._element
        ..on-change @on-is_obligated-change

      .._elements.'is_pep'._element
        ..on-change @on-is_pep-change

      .._elements.'money_source'._element
        ..on-key-up (evt) ~>
            if evt.key-code is 77 and evt.ctrl-key   # [ctrl+M]
              mdl = modal.Modal._new do
                  _title: 'Tabla de Fondos.'
                  _body: @table-money-source!
              mdl._show!

      # Update issuance_country by document_type
      issuance-country-el = .._elements.'issuance_country'._element
        .._value = 'Perú'

      .._elements.'document_type'._element.on-change (evt) ->
        doc-type-el = evt._target
        if doc-type-el._value is 'dni'
          issuance-country-el._value = 'Perú'
        else
          issuance-country-el._value = ''

      ..render!

    super!

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR
  ratio: null

  /** FIELD */
  _FIELD_PERSON =
    * _name: 'name'
      _label: 'a) Nombres'

    * _name: 'father_name'
      _label: 'Apellido Paterno'

    * _name: 'mother_name'
      _label: 'Apellido Materno'

    * _name: 'document_type'
      _label: 'b) Tipo documento'
      _tip: 'Tipo de documento de la persona en cuyon nombre se
           \ realiza la operación.'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document_number'
      _label: 'Número documento identidad'
      _tip: 'Número de documento de la persona en cuyo nombre se realiza
           \ la operación.'

    * _name: 'issuance_country'
      _label: 'País documento emitido extranjero'
      _tip: 'País de emisión del documento de la persona en cuyo nombre
           \ se realiza la operación.'

    * _name: 'ruc'
      _label: 'c) RUC, de ser el caso'
      _tip: 'Número de RUC de la persona en cuyo nombre se realiza la operación.'

    * _name: 'birthplace'
      _label: 'd) Lugar de nacimiento'

    * _name: 'birthday'
      _label: 'Fecha de nacimiento'

    * _name: 'nationality'
      _label: 'e) Nacionalidad'
      _tip: 'Nacionalidad de la persona en cuyo nombre se realiza
           \ la operación.'

    * _name: 'address'
      _label: 'f) Domicilio declarado (lugar de residencia)'

    * _name: 'fiscal_address'
      _label: 'g) Domicilio fiscal, de ser el caso'

    * _name: 'phone'
      _label: 'h) Número telefono fijo'

    * _name: 'mobile'
      _label: 'Número de celular'

    * _name: 'email'
      _label: 'i) Correo electrónico'
      _placeholder: 'domain@domain.com'

    * _name: 'activity'
      _label: 'j) Profesión u ocupación'
      _tip: 'Ocupación, oficio o profesión de la persona en cuyo nombre se
           \ realiza la operación.([ctrl+M] para ver la tabla completa)'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.activity._display
                   _field : 'activity'

    * _name: 'civil_state'
      _label: 'k) Estado civil'
      _type: FieldType.kComboBox
      _options:
        'Soltero'
        'Casado'
        'Viudo'
        'Divorciado'
        'Conviviente'

    * _name: 'partner'
      _label: 'Nombre Conviviente o Conyuge'
      _field-attrs: _FIELD_ATTR._disabled

    * _name: 'money_source_type'
      _label: 'l) Tipo de Fondos'
      _type: FieldType.kComboBox
      _options:
        'No efectivo'
        'Efectivo'

    * _name: 'money_source'
      _label: 'm) Origen de los fondos'

    * _name: 'is_obligated'
      _label: 'n) Si es Sujeto obligado'
      _type: FieldType.kYesNo

    * _name: 'has_officer'
      _label: 'Oficial cumplimiento'
      _type: FieldType.kYesNo

    * _name: 'reference'
      _label: 'Ref. Cliente'
      _tip: 'Referencia del cliente.'
      _grid: _GRID._inline

    * _name: 'is_pep'
      _label: 'Es persona PEP?'
      _type: FieldType.kYesNo

    * _name: 'employment'
      _label: 'Cargo o función pública'
      _tip: 'Si es PEP, debe indicar el cargo público
           \ ([ctrl+M] para ver la tabla No 3 completa)'
      _type: FieldType.kView
      _field-attrs: _FIELD_ATTR._disabled
      _options : new InputName do
                   _name : App.lists.office._display
                   _field : 'employment'

    * _name: 'employer'
      _label: 'Empleador'
      _tip: 'En caso de ser dependiente'

    * _name: 'average_income'
      _label: 'Ingresos promedios mensuales'


/** @export */
module.exports = Person


# vim: ts=2:sw=2:sts=2:et
