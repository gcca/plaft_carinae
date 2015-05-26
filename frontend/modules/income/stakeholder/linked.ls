/** @module modules */

widget = App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField

panelgroup = App.widget.panelgroup

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair


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
        FIELD = @_FIELD_PERSON
        TYPE = @@Type.kPerson

      else
        FIELD = @_FIELD_BUSINESS
        TYPE = @@Type.kBusiness

      @render-skateholder FIELD, TYPE
    super _dto

  _json-getter: ->
    _dto = super!
    delete! _dto.'customer_type'
    _dto

  /**
   * @param {Array.<FieldOptions>} _fields
   * @param {Integer} _next-type
   * @private
   */
  render-skateholder: (_fields, _next-type) ->
    @el._last.html = ''
    App.builder.Form._new @el._last, _fields
      @_person-type-html = .._elements.'customer_type'._element
      ..render!
      .._free!
    @_person-type-html._selected-index = _next-type
    @_person-type-html.on-change ~>
      @_render-by-type!

  /** @see render-stakeholder */
  _render-by-type: ->
    _type = @_type!

    if _type is @@Type.kPerson
      @render-skateholder @_FIELD_PERSON, _type

    if _type is @@Type.kBusiness
      @render-skateholder @_FIELD_BUSINESS, _type

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
    @render-skateholder @_FIELD_BUSINESS, @@Type.kBusiness
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

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

  /** FIELD */
  _FIELD_HEAD :
    * _name: 'linked_type'
      _label: 'Tipo de vinculación'
      _type: FieldType.kComboBox
      _options:
        'Proveedor'
        'Destinatario de embarque'

    * _name: 'customer_type'
      _label: 'Tipo Persona'
      _type: FieldType.kComboBox
      _options:
        'Natural'
        'Jurídica'

  /** FIELD */
  _FIELD_PERSON :
    * _name: 'father_name'
      _label: 'Apellido paterno'

    * _name: 'mother_name'
      _label: 'Apellido materno'

    * _name: 'name'
      _label: 'Nombre completo'

    * _name: 'issuance_country'
      _label: 'País de emisión del documento'

    * _name: 'address'
      _label: 'Nombre y N° de la vía dirección'

    * _name: 'phone'
      _label: 'Teléfono de la persona'

    * _name: 'nationality'
      _label: 'Nacionalidad'

    * _name: 'document_type'
      _type: FieldType.kHidden
      _options: <[dni]>

  /** FIELD */
  _FIELD_BUSINESS :
    * _name: 'name'
      _label: 'Razon social'

    * _name: 'social_object'
      _label: 'Objeto social'

    * _name: 'activity'
      _label: 'Actividad económica principal'

    * _name: 'address'
      _label: 'Nombre y N° via direccion'

    * _name: 'phone'
      _label: 'Teléfono de la persona en cuyo nombre'

    * _name: 'country'
      _label: ''  # origen o destino (importación o exportación)
                  # según el tipo de operación. Ver en el builder.
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
