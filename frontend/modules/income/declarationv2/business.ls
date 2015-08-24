/** @module modules.income */


Customer = require './customer'

modal = App.widget.message-box

App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField
table = App.widget.table
  SimpleTable = ..SimpleTable

Shareholders = require './shareholders'

FormRatio = App.form-ratio

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair


class Business extends Customer

  /** @override */
  _tagName: \form

  /** @override */
  _json-getter: ->
    _r = super!
      ..'document_type' = 'ruc'
      ..'shareholders' = @shareholders-view._toJSON!

    if not @ratio?
      @ratio = new FormRatio do
        fields: _FIELD_BUSINESS
        el: @el
    _ratio =  @ratio._calculate _r
    if _ratio isnt 0
      @_panel._header._get panelgroup.ControlBar ._set-bar _ratio

    _r

  _json-setter: (_dto) ->
    @shareholders-view.shareholders._length = 0
    @shareholders-view.load-from _dto.'shareholders'
    super _dto
    # Progress Bar
    @ratio = new FormRatio do
      fields: _FIELD_BUSINESS
      el: @el
    _ratio =  @ratio._calculate _dto

    if _ratio isnt 0
      @_panel._header._get panelgroup.ControlBar ._set-bar _ratio

  /** @protected */
  set-default-type: -> @set-type 'j'

  /** @override */
  render: ->
    @form-builder = new App.builder.Form @el, _FIELD_BUSINESS
      @shareholders-view = .._elements.'shareholders'._view

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

    * _name: 'document_number'
      _label: 'b) N&ordm; RUC'

    * _name: 'link_type'
      _label: 'c) Condición en la que se realiza operación'
      _type: FieldType.kComboBox
      _tip : 'Importador/Consignatario, Exportador/Consignante'
      _options:
        'Importador'
        'Exportador'

    * _name: 'social_object'
      _label: 'd) Objeto Social'

    * _name: 'activity'
      _label: 'Actividad económica principal'
      _tip: 'Actividad económica de la persona en cuyo nombre se realiza la
           \ operación. ([ctrl+M] para ver la tabla de actividad económica)'

    * _name: 'shareholders'
      _label: 'e) Identificacion accionistas '
      _tip : 'Socios o asociados, que tengan un % igual o mayor a 25% accionistas)'
      _grid: _GRID._full
      _type: FieldType.kView
      _options: new Shareholders

    * _label: 'f) Identificación del representante legal o de quien comparece \
               con facultades representación'
      _type: FieldType.kLabel
      _grid: _GRID._inline

    * _name: 'legal_document_type'
      _label: 'Tipo documento'
      _tip: 'Representante legal de la empresa.'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'legal_document_number'
      _label: 'Número de documento'
      _tip: 'Representante legal de la empresa.'

    * _name: 'legal_name'
      _label: 'Apellidos y nombres'

    * _label: 'g) Domicilio'
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
      _label: 'h) Telefono fijos de la oficina principal'

    * _name: 'money_source'
      _label: 'i) El origen fondos, bienes u otros activos'

    * _name: 'money_source_type'
      _label: 'i) Tipo de Fondos'
      _type: FieldType.kComboBox
      _options:
        'No efectivo'
        'Efectivo'

    * _label: 'j) Identificación del declarante'
      _type: FieldType.kLabel
      _grid: _GRID._inline

/** @export */
module.exports = Business


# vim: ts=2:sw=2:sts=2:et
