/** @module modules */

widget = App.widget.codename
  InputName = ..InputName
  CodeNameField = ..CodeNameField

panelgroup = require '../../../app/widgets/panelgroup'
  PanelBody = ..PanelBody

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

/**
 * Stakeholder
 * -----------
 * @class Stakeholder
 * @extends View
 */
class Stakeholder extends PanelBody

  /**
   * @param {Array.<FieldOptions>} _fields
   * @param {Integer} _next-type
   * @private
   */
  render-customer: (_fields, _next-type) ->
    @_body._first._last
      ..html=''
      App.builder.Form._new .., _fields
        @_person-type-html = .._elements['customer_type']._element
        ..render!
        .._free!
    @_person-type-html._selected-index = _next-type
    @_person-type-html.on-change @_on-render


  /**
   * Modifica el formulario segun el customer_type.
   * @private
   */
  _on-render: ~>
    _type = @_type!

    if _type is @@Type.kPerson
      @render-customer _FIELD_PERSON, _type
      @el.query '[name= is_pep]' .attr('checked',on)
      _pep = @el.query '[name=pep_position]'

      @el.query '[value=Sí]' .on-change ~>
         _pep._disabled = off

      @el.query '[value=No]' .on-change ~>
         _pep._disabled = on

      @trigger (gz.Css \change), _type

    if _type is @@Type.kBusiness
      @render-customer _FIELD_BUSINESS, _type
      _country = @el.query '[name=country]'
      @_link-type.on-change (evt) ~>
        if evt._target._value is \Proveedor
          _country._parent._first.html = 'Pais Origen'
        else
          _country._parent._first.html = 'Pais Destino'

      @trigger (gz.Css \change), _type

  /**
   * Carga el formulario segun el dto.
   */
  read-dto: (dto) ->
    if @_options.dto.'customer_type' is \Natural
      FIELD = _FIELD_PERSON
      TYPE = @@Type.kPerson
    else
      FIELD = _FIELD_BUSINESS
      TYPE = @@Type.kBusiness
    @render-customer FIELD, TYPE
    @_body._first ._fromJSON @_options.dto

  /**
   * Obtiene el codigo de customer_type
   * @private
   */
  _type: ->
    @_person-type-html._selected-index

  /** @override */
  render: ->
    ret = super!
    @_body = @el.query '.panel-body'
    $ @_body ._append "<form></form>"

    App.builder.Form._new @_body._first, _FIELD_HEAD
      .._elements['customer_type']._field
        ._class +=" #{gz.Css \bg-warning}
                  \ #{gz.Css \has-warning}"
      ..render!
      .._free!

    @_link-type = @el.query '[name = link_type]'
    $ @_body._first ._append "<div></div>"

    FIELD = _FIELD_BUSINESS
    TYPE = @@Type.kBusiness
    if @_options.dto?
      if @_options.dto.'customer_type' is \Natural
        FIELD = _FIELD_PERSON
        TYPE = @@Type.kPerson
      else
        FIELD = _FIELD_BUSINESS
        TYPE = @@Type.kBusiness

    @render-customer FIELD, TYPE
    @_body._first ._fromJSON @_options.dto
    ret

  /** @private */ _person-type-html: null
  /** @private */ _link-type: null

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

  /**
   * Opciones de Tipo de Persona
   */
  @@Type =
    kPerson: 0
    kBusiness: 1

  /** FIELD */
  _FIELD_HEAD =
    * _name: 'link_type'
      _label: 'Tipo de vinculación'
      _type: FieldType.kComboBox
      _options:
        'Proveedor'
        'Destinatario'

    * _name: 'customer_type'
      _label: 'Tipo Persona'
      _type: FieldType.kComboBox
      _options:
        'Natural'
        'Jurídica'

  /** FIELD */
  _FIELD_PERSON =
    * _name: 'document_type'
      _label: 'Tipo de documento de identidad'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document_number'
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
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.office._display
                   _field : 'pep_position'

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
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.activity._display
                   _field : 'pep_position'

    * _name: 'employer'
      _label: 'Empleador (en caso de ser dependiente)'
      _type: FieldType.kRadioGroup
      _options: <[Sí No]>

    * _name: 'average_monthly_income'
      _label: 'Ingresos promedios mensuales'

    * _name: 'position'
      _label: 'Cargo (si aplica)'
      _type: FieldType.kView
      _options : new InputName do
                   _name : App.lists.office._display
                   _field : 'pep_position'

    * _name: 'address'
      _label: 'Nombre y N° de la vía dirección'

    * _name: 'phone'
      _label: 'Teléfono de la persona operación'

  /** FIELD */
  _FIELD_BUSINESS =
    * _name: 'name'
      _label: 'Razon social'

    * _name: 'social_object'
      _label: 'Objeto social'

    * _name: 'address'
      _label: 'Nombre y N° via direccion'

    * _name: 'phone'
      _label: 'Teléfono de la persona en cuyo nombre'

    * _name: 'country'
      _label: 'País origen'

/** @export */
module.exports = Stakeholder


# vim: ts=2:sw=2:sts=2:et
