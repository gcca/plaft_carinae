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
    _r = super!
    if not @ratio?
      @ratio = new FormRatio do
        fields: _FIELD_PERSON
        el: @el
    _ratio =  @ratio._calculate _r
    if _ratio isnt 0
      @_panel._header._get panelgroup.ControlBar ._set-bar _ratio
    _r

  _json-setter: (_dto) ->
    pep-date = @form-builder._elements.'pep_is_date'._radios

    if _dto.'pep_is_date'?
      if _dto.'pep_is_date'
        pep-date._yes._checked = true
      else
        pep-date._no._checked = true
    super _dto
    # Progress Bar
    @ratio = new FormRatio do
      fields: _FIELD_PERSON
      el: @el
    _ratio =  @ratio._calculate _dto

    if _ratio isnt 0
      @_panel._header._get panelgroup.ControlBar ._set-bar _ratio
    @on-document_type-change!
    @on-pep_country-change!

  /** @protected */
  set-default-type: -> @set-type 'n'

  clean-text: (text-field, disabled=on) ->
    text-field._value = ''
    text-field._disabled = disabled

  on-document_type-change: ~>
    other = @form-builder._elements.'other_document'._element
    (@el.query '[name=document_type]')._selected-index
      switch ..
        | 7 => other._disabled = @clean-text other, off
        | otherwise => @clean-text other

  on-pep_country-change: ~>
    description = @form-builder._elements.'pep_country_description'._element
    pep-country = @el.query '[name=pep_country]:checked'
    if not pep-country?
      return
    else if pep-country._value is \Perú
      @clean-text description
    else
      @clean-text description, off


  /** @override */
  render: ->
    @form-builder = new App.builder.Form @el, _FIELD_PERSON

      .._elements.'document_type'._element
        ..on-change @on-document_type-change

      .._elements.'pep_country'._element
        ..on-change @on-pep_country-change

      ..render!

    super!

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

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

    * _name: 'other_document'
      _label: 'Especifique otro documento'

    * _name: 'link_type'
      _label: 'c) Condición en la que se realiza operación'
      _type: FieldType.kComboBox
      _tip : 'Importador/Consignatario, Exportador/Consignante'
      _options:
        'Importador'
        'Exportador'

    * _name: 'nationality'
      _label: 'd) Nacionalidad'
      _tip: 'Nacionalidad de la persona en cuyo nombre se realiza
           \ la operación.'

    * _label: 'e) Domicilio'
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
      _grid: _GRID._inline

    * _name: 'phone'
      _label: 'f) N&ordm; teléfono fijo'

    * _name: 'mobile'
      _label: 'N&ordm; celular'

    * _name: 'email'
      _label: 'g) Correo electrónico'
      _placeholder: 'domain@domain.com'

    * _name: 'activity'
      _label: 'h) Profesión u ocupación'
      _tip: 'Ocupación, oficio o profesión de la persona en cuyo nombre se
           \ realiza la operación.([ctrl+M] para ver la tabla completa)'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.activity._display
                   _field : 'activity'

    * _name: 'work_center'
      _label: 'Centro de labores'

    * _label: 'i) Cumple o en los últimos cinco años ha cumplido funciones \
              destacadas o funciones prominentes en una organización \
              internacional, sea en el territorio nacional o extranjero \
              o, y cuyas circunstancias financieras puedan ser objeto \
              de un interés público.'
      _type: FieldType.kLabel
      _grid: _GRID._inline

    * _name: 'pep_is_date'
      _label: 'Desempeña a la fecha'
      _type: FieldType.kYesNo

    * _name: 'pep_country'
      _label: 'En el '
      _type: FieldType.kRadioGroup
      _options:
        'Perú'
        'En el extranjero'

    * _name: 'pep_country_description'
      _label: 'Indique país'

    * _name: 'pep_employment'
      _label: 'Cargo o función pública'
      _tip: 'Si es PEP, debe indicar el cargo público
           \ ([ctrl+M] para ver la tabla No 3 completa)'
      _type: FieldType.kView
      _field-attrs: _FIELD_ATTR._disabled
      _options : new InputName do
                   _name : App.lists.office._display
                   _field : 'employment'

    * _name: 'pep_organization'
      _label: 'Nombre del organismo público u organización internacional'

    * _name: 'money_source'
      _label: 'j) El origen fondos, bienes u otros activos'

    * _name: 'money_source_type'
      _label: 'Tipo de fondos'
      _type: FieldType.kComboBox
      _options:
        'No efectivo'
        'Efectivo'

    * _label: 'k) Identificación del declarante'
      _type: FieldType.kLabel
      _grid: _GRID._full


/** @export */
module.exports = Person


# vim: ts=2:sw=2:sts=2:et
