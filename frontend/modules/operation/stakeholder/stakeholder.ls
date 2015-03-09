/** @module modules */

panelgroup = require '../../../app/widgets/panelgroup'
  Panel = ..Panel

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
class Stakeholder extends Panel

  /**
   * @param {Array.<FieldOptions>} _fields
   * @param {number} _next-type
   * @private
   */
  render-customer: (_fields, _next-type) ->
    @_body._first._last
      ..html=''
      App.builder.Form._new .., _fields
        _pdescription = .._elements'description_position'._element
        @_person-type-html = .._elements['person_type']._element
        .._elements['position']._element .on-change (evt)~>
              if evt._target._value is 'OTRO (señalar)'
               _pdescription._parent.css = ""
              else
               _pdescription._parent.css = "display:none"
        ..render!
        .._free!
    @_person-type-html._selected-index = _next-type
    @_person-type-html.on-change @_on-render

    @_panel-heading.overload-for-title _next-type

  /*
   *
   * TODO
   * @private
   */
  _on-render: ~>
    _type = @_type!
    if _type is @@Type.kPerson
      @render-customer _FIELD_PERSON, _type
      @el.query '[name= is_pep]' .attr('checked',on)
      _adescription = @el.query '[name=activity_description]'
      _pep = @el.query '[name=pep_position]'
      _pepdesc = @el.query '[name=pep_description]'

      @el.query '[name= document_type]' .on-change (evt) ~>
        if evt._target._value is \005
          @el.query '[name=nationality]' ._value='Peruana'
          @el.query '[name=nationality]' ._disabled=on
        else
          @el.query '[name=nationality]' ._value=''
          @el.query '[name=nationality]' ._disabled=off

      @el.query '[name=activity]' .on-change (evt)~>
        if evt._target._value is \OTROS
          _adescription._parent.css = ""
        else
          _adescription._parent.css = "display:none"

      @el.query '[value=Sí]' .on-change ~>
         _pep._disabled = off

      @el.query '[value=No]' .on-change ~>
         _pep._disabled = on

      _pep.on-change (evt) ~>
        if evt._target._value is 'OTRO (señalar)'
          _pepdesc._parent.css = ""
        else
          _pepdesc._parent.css = "display:none"



    if _type is @@Type.kBusiness
      @render-customer _FIELD_BUSINESS, _type
      _country = @el.query '[name=country]'
      @_link-type.on-change (evt)~>
        if evt._target._value is \Proveedor
          _country._parent._first.html = 'Pais Origen'
        else
          _country._parent._first.html = 'Pais Destino'


  /*
   * TODO
   * @private
   */
  _type: ->
    @_person-type-html._selected-index

  /** @override */
  render: ->
    ret = super!

    @_body = @_panel-body._get-el!

    @_body.html = "<form></form>"

    App.builder.Form._new @_body._first, _FIELD_HEAD
      .._elements['person_type']._field
        ._class +=" #{gz.Css \bg-warning}
                  \ #{gz.Css \has-warning}"
      ..render!
      .._free!
    @_link-type = @el.query '[name = link_type]'
    $ @_body._first ._append "<div></div>"
    @_panel-heading.set-title-heading 'Vinculado'
    @render-customer _FIELD_BUSINESS, @@Type.kBusiness
    _country = @el.query '[name=country]'
    @_link-type.on-change (evt)~>
      if evt._target._value is \Proveedor
        _country._parent._first.html  = 'Pais Origen'
      else
        _country._parent._first.html  = 'Pais Destino'
    @_panel-heading.overload-for-title!
    @_toggle!
    ret


  /** @private */ _person-type-html: null
  /** @private */ _link-type: null
  /** @private */ _body: null

  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

  @@Type =
    kPerson: 0
    kBusiness: 1

  _FIELD_HEAD =
    * _name: 'link_type'
      _label: 'Tipo de vinculación'
      _type: FieldType.kComboBox
      _options:
        'Proveedor'
        'Destinatario'

    * _name: 'person_type'
      _label: 'Tipo Persona'
      _type: FieldType.kComboBox
      _options:
        'Natural'
        'Juridico'

  _FIELD_PERSON =
    * _name: 'document_type'
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

    * _name: 'pep_description'
      _label: 'Descripcion del Cargo Público (en caso de "Otros")'
      _grid: _GRID._inline
      _hide: on

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

    * _name: 'activity_description'
      _label: 'Descripcion de la ocupación (en caso de "Otros")'
      _grid: _GRID._inline
      _hide: on

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

    * _name: 'description_position'
      _label: 'Descripción del Cargo (en caso de "Otros")'
      _hide: on

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

    * _name: 'description_position'
      _label: 'Descripción del Cargo (en caso de "Otros")'
      _hide: on

    * _name: 'address'
      _label: 'Nombre y N° via direccion'

    * _name: 'phone'
      _label: 'Teléfono de la persona en cuyo nombre'

    * _name: 'country'
      _label: 'País origen'

/** @export */
module.exports = Stakeholder


# vim: ts=2:sw=2:sts=2:et
