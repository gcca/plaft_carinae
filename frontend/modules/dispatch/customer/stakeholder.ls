/** @module modules */

PanelGroup = require '../../../app/widgets/panelgroup'

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

/**
 * Stakeholder
 * ----------
 * TODO
 *
 * @class Stakeholder
 * @extends View
 */
class Stakeholder extends App.View

  /** @override */
  _tagName: \form

  /** @override */
  _className: gz.Css \col-md-12

  /*
   *
   * TODO
   * @private
   */
  overload-for-title: ->
    _type = @_type!

    if _type is @@Type.kBusiness
      @el.query '[name=name]' .on-key-up (evt) ~>
        @_content-title.html = evt._target._value

    if _type is @@Type.kPerson
      _name = @el.query '[name=name]'
      _father_name = @el.query '[name=father_name]'
      _mother_name = @el.query '[name=mother_name]'

      _set-title = ~>
        @_content-title.html = _name._value + ' ' \
                               + _father_name._value + ' ' \
                               + _mother_name._value

      _name.on-key-up _set-title
      _father_name.on-key-up _set-title
      _mother_name.on-key-up _set-title

  /**
   * @param {Array.<FieldOptions>} _fields
   * @param {number} _next-type
   * @private
   */
  render-customer: (_fields, _next-type) ->
    @el._last
      ..html=''
      App.builder.Form._new .., _fields
        @_person-type-html = .._elements['person_type']._element
        ..render!
        .._free!

    @_person-type-html._selected-index = _next-type
    @_person-type-html.on-change @_on-render

    @overload-for-title!

  /*
   *
   * TODO
   * @private
   */
  _on-render: ~>
    _type = @_type!
    if _type is @@Type.kPerson
      @render-customer _FIELD_PERSON, _type
    if _type is @@Type.kBusiness
      @render-customer _FIELD_BUSINESS, _type

  /*
   * TODO
   * @private
   */
  _type: ->
    @_person-type-html._selected-index

  /**
   * @param {HTMLElement} content-title
   * @override
   */
  initialize: ({@_content-title}) -> super!

  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELD_HEAD
      .._elements['person_type']._field
        ._class +=" #{gz.Css \bg-warning}
                  \ #{gz.Css \has-warning}"
      ..render!
      .._free!
    @$el._append "<div class='#{gz.Css \form-group}'></div>"

    @render-customer _FIELD_BUSINESS, @@Type.kBusiness

    super!


  /** @private */ _person-type-html: null
  /** @private */ _content-title: null


  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID

  @@Type =
    kPerson: 0
    kBusiness: 1

  _FIELD_HEAD =
    * _name: 'link_type'
      _label: 'Tipo de vinculación'
      _type: FieldType.kComboBox
      _options:
        'Proveedor'
        'Importador'
        'Exportador'
        'Destinatario'

    * _name: 'person_type'
      _label: 'Tipo Persona'
      _type: FieldType.kComboBox
      _options:
        'Natural'
        'Juridico'

  _FIELD_PERSON =
    * _name: 'document[type]'
      _label: 'Tipo de documento de identidad'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document[number]'
      _label: 'Número de documento de identidad'

    * _name: 'residence_status'
      _label: 'Condición de residencia'
      _type: FieldType.kComboBox
      _options:
        'Residente'
        'No residente'

    * _name: 'issuance_country'
      _label: 'País de emisión del documento'

    * _name: 'is_pep'
      _label: '¿La persona es PEP?'
      _type: FieldType.kRadioGroup
      _options: <[Sí No]>

    * _name: 'pep_position'
      _label: 'Cargo Público'
      _type: FieldType.kComboBox
      _options: App.lists.office._display

    * _name: 'father_name'
      _label: 'Apellido paterno'

    * _name: 'mother_name'
      _label: 'Apellido materno'

    * _name: 'name'
      _label: 'Nombres'

    * _name: 'nationality'
      _label: 'Nacionalidad'

    * _name: 'birthday'
      _label: 'Fecha de nacimiento'
      _placeholder: 'dd/mm/aaaa'

    * _name: 'activity'
      _label: 'Ocupación, oficio o profesión'
      _type: FieldType.kComboBox
      _options: App.lists.activity._display

    # * _name: 'activity_description'
    #   _label: 'Descripcion de la ocupación (en caso de "Otros")'

    * _name: 'employer'
      _label: 'Empleador (en caso de ser dependiente)'
      _type: FieldType.kRadioGroup
      _options: <[Sí No]>

    * _name: 'average_monthly_income'
      _label: 'Ingresos promedios mensuales'

    * _name: 'position'
      _label: 'Cargo (si aplica)'
      _type: FieldType.kComboBox
      _options: App.lists.office._display

    * _name: 'address'
      _label: 'Nombre y N° de la vía dirección'

    * _name: 'phone'
      _label: 'Teléfono de la persona operación'

  _FIELD_BUSINESS =
    * _name: 'name'
      _label: 'Razon social'

    * _name: 'social_object'
      _label: 'Objeto social'

    * _name: 'position'
      _label: 'Cargo (si aplica)'
      _type: FieldType.kComboBox
      _options: App.lists.office._display

    * _name: 'address'
      _label: 'Nombre y N° via direccion'

    * _name: 'phone'
      _label: 'Teléfono de la persona en cuyo nombre'

    * _name: 'country'
      _label: 'País origen o destino (según el caso)'

/**
 * Stakeholders
 * ----------
 * TODO
 *
 * @class Stakeholders
 * @extends View
 */

class Stakeholders extends App.View

  /** @override */
  _tagName: \div

  /*
   *
   * TODO
   * @private
   */
  add-stakeholder: ~>
    @panel-group.close-all!
    @panel-group.new-panel 'Vinculado'

      stk = Stakeholder._new _content-title: .._header._first._first
      .._body._append stk.render!.el

      .._toggle!
    @el._first._append @panel-group.render!.el

  /** @override */
  initialize:->
    @panel-group = new PanelGroup

  /** @override */
  render: ->
    @el.html = "<div class='#{gz.Css \col-md-12}'></div>
                <button type='button'
                        class= '#{gz.Css \btn}
                              \ #{gz.Css \btn-default}'>
                Agregar
                </button>"
    @el._last.on-click @add-stakeholder

    super!

  /** @private */ panel-group :null


/** @export */
module.exports = Stakeholders


# vim: ts=2:sw=2:sts=2:et
