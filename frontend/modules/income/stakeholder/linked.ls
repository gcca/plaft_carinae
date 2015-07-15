/** @module modules */

widget = App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField

modal = App.widget.message-box

panelgroup = App.widget.panelgroup

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

FormRatio = App.form-ratio

/**
 * Linked
 * -----------
 * @class Linked
 * @extends View
 */
class FormLinked extends panelgroup.FormBody

  _json-setter: (_dto) ->
    if _dto.'document_type'?
      if _dto.'document_type' isnt \ruc
        @_FIELD = @_FIELD_PERSON
        TYPE = @@Type.kPerson

      else
        @_FIELD = @_FIELD_BUSINESS
        TYPE = @@Type.kBusiness

      @render-skateholder @_FIELD, TYPE
      # Progress Bar
      @ratio = new FormRatio do
        fields: @_FIELD
        el: @el
      _ratio =  @ratio._calculate _dto
      if _ratio isnt 0
        @_panel._header._get panelgroup.ControlBar ._set-bar _ratio
    super _dto

  _json-getter: ->
    _dto = super!
    delete! _dto.'customer_type'
    if not @ratio?
      @ratio = new FormRatio do
        fields: @_FIELD
        el: @el
    _ratio =  @ratio._calculate _dto
    @_panel._header._get panelgroup.ControlBar ._set-bar _ratio
    _dto

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

  /**
   * @param {Array.<FieldOptions>} _fields
   * @param {Integer} _next-type
   * @private
   */
  render-skateholder: (_fields, _next-type) ->
    @el._last.html = ''
    App.builder.Form._new @el._last, _fields
      @_person-type-html = .._elements.'customer_type'._element
      .._elements.'activity'._element
        ..on-key-up (evt) ~>
            if evt.key-code is 77 and evt.ctrl-key   # [ctrl+M]
              mdl = modal.Modal._new do
                  _title: 'Tabla de actividad económica.'
                  _body: @template-table!
              mdl._show!
      ..render!
      .._free!
    @_person-type-html._selected-index = _next-type
    @_person-type-html.on-change ~>
      @_render-by-type!

  /** @see render-stakeholder */
  _render-by-type: ->
    _type = @_type!

    if _type is @@Type.kPerson
      @_FIELD = @_FIELD_PERSON

    if _type is @@Type.kBusiness
      @_FIELD = @_FIELD_BUSINESS

    @render-skateholder @_FIELD, _type

  /**
   * Obtiene el codigo de customer_type
   * @private
   */
  _type: ->
    @_person-type-html._selected-index

  /** @override */
  render: ->
    ret = super!
    App.builder.Form._new @el, @_FIELD_HEAD
      .._elements['customer_type']._field
        ._class +=" #{gz.Css \bg-warning}
                  \ #{gz.Css \has-warning}"
      ..render!
      .._free!
    @$el._append "<div></div>"
    @_FIELD = @_FIELD_BUSINESS
    @render-skateholder @_FIELD, @@Type.kBusiness
    @_panel.on (gz.Css \load-body), (_dto) ~>
      @_json = _dto
    ret

  /** @private */ _person-type-html: null

  /**
   * Update text for country.
   * @param {string} _in-or-out Label.
   * @see _operation-type-to-{in,out}
   */
  @@_operation-type-to = (_in-or-out, _in-or-out-select) ->
    FormLinked::_FIELD_BUSINESS.5._label = 'Código de país de ' + _in-or-out
    FormLinked::_FIELD_HEAD.0._options = [_in-or-out-select]

  @@_operation-type-to-in = ->
    @_operation-type-to 'origen', 'Proveedor'

  @@_operation-type-to-out = ->
    @_operation-type-to 'destino', 'Destinatario de embarque'

  /**
   * Opciones de Tipo de Persona
   */
  @@Type =
    kPerson: 0
    kBusiness: 1

  _FIELD : null
  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

  ratio: null

  /** FIELD */
  _FIELD_HEAD :
    * _name: 'link_type'
      _label: 'Tipo de vinculación'
      _type: FieldType.kComboBox
      _tip: 'La persona en cuyo nombre se realiza la operación es: (1) Proveedor
           \ del extranjero (ingreso de mercancía), (2)Destinatario de Embarque
           \ (salida de mercancía).'
      _options:
        'Proveedor'
        'Destinatario de embarque'

    * _name: 'customer_type'
      _label: 'Tipo Persona'
      _type: FieldType.kComboBox
      _tip: 'La persona en cuyo nombre se realiza la operación ha sido
           \ representado.'
      _options:
        'Natural'
        'Jurídica'

  /** FIELD */
  _FIELD_PERSON :
    * _name: 'father_name'
      _label: 'Apellido paterno'
      _tip: 'Apellido paterno de la persona en cuyo nombre se realiza la
           \ operación.'

    * _name: 'mother_name'
      _label: 'Apellido materno'
      _tip: 'Apellido materno de la persona en cuyo nombre se realiza la
           \ operación.'

    * _name: 'name'
      _label: 'Nombre completo'
      _tip: 'Nombres de la persona en cuyo nombre se realiza la operación.'

    * _name: 'issuance_country'
      _label: 'País de emisión del documento'
      _tip: 'País de emisión del documento de la persona en cuyo nombre se
           \ realiza la operación.'

    * _name: 'address'
      _label: 'Nombre y N° de la vía dirección'
      _tip: 'Nombre y número de la vía de la dirección de la persona en cuyo
           \ nombre se realiza la operación.'

    * _name: 'phone'
      _label: 'Teléfono de la persona'
      _tip: 'Teléfono de la persona en cuyo nombre se realiza la operación.'

    * _name: 'nationality'
      _label: 'Nacionalidad'
      _tip: 'Nacionalidad de la persona en cuyo nombre se realiza la operación.'

    * _name: 'document_type'
      _type: FieldType.kHidden
      _options: <[dni]>

  /** FIELD */
  _FIELD_BUSINESS :
    * _name: 'name'
      _label: 'Razon social'
      _tip: 'Razón social de la persona en cuyo nombre se realiza la operación.'

    * _name: 'social_object'
      _label: 'Objeto social'

    * _name: 'activity'
      _label: 'Actividad económica principal'
      _tip: 'Actividad económica de la persona en cuyo nombre se realiza la
           \ operación(persona jurídica u otras formas de organización o
           \ asociación que la Ley establece): Consignar la actividad
           \ principal.([ctrl+M] para ver la tabla de actividad económica)'

    * _name: 'address'
      _label: 'Nombre y N° via direccion'
      _tip: 'Nombre y número de la vía de la dirección de la persona en cuyo
           \ nombre se realiza la operación.'

    * _name: 'phone'
      _label: 'Teléfono de la persona en cuyo nombre'
      _tip: 'Teléfono de la persona en cuyo nombre se realiza la operación.'

    * _name: 'country'
      _label: ''  # origen o destino (importación o exportación)
                  # según el tipo de operación. Ver en el builder.
      _tip: 'Pais de origen/Pais de destino'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.country-sbs._display
                   _field : 'country'

    * _name: 'document_type'
      _type: FieldType.kHidden
      _options: <[ruc]>

/** @export */
module.exports = FormLinked


# vim: ts=2:sw=2:sts=2:et
