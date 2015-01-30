/**
 * @module customer
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */


Shareholders = require './shareholders'

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair


class Third extends App.View

  _tagName: \div

  _className: "#{gz.Css \form-group} #{gz.Css \col-md-12}
             \ #{gz.Css \has-error} #{gz.Css \has-feedback}"

  render-fields: (_fields) ->
    @el._last
      ..html = ''
      App.builder.Form._new .., _fields
        .._class gz.Css \col-md-6
        ..render!
        .._free!

  load-person: ~>
    @render-fields _FIELDS_PERSON

  load-business: ~>
    @render-fields _FIELDS_BUSINESS

  render: ->
    # Highlight dynamic field
    @el.html = "<h4 class='#{gz.Css \control-label}'>Tercero</h4>
                <div></div><div></div>"

    radio-person = App.dom._new \input
      .._name = \third_type
      .._type = \radio
      ..on-click @load-person

    radio-business = App.dom._new \input
      .._name = \third_type
      .._type = \radio
      ..on-click @load-business

    @el._first._next
      .._append radio-person
      .._append App.dom.create-text-node ' Natural'
      .._append App.dom._new \span
        ..html = '&nbsp;'*8
      .._append radio-business
      .._append App.dom.create-text-node ' Jurídica'

    super!


  /** Field list for person form. (Array.<FieldOptions>) */
  _FIELDS_PERSON =
    * _name: 'document[type]'
      _label: 'Tipo documento'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document[number]'
      _label: 'Número documento identidad'

    * _name: 'father_name'
      _label: 'Apellido paterno'

    * _name: 'mother_name'
      _label: 'Apellido materno'

    * _name: 'name'
      _label: 'Nombres'

  /** Field list for business form. (Array.<FieldOptions>) */
  _FIELDS_BUSINESS = [
    * _name: 'name'
      _label: 'Razón social']

  _OK = [{
    _name: 'ok',
    _label: 'Persona a favor (1) imp (2) Dest embarq'}]

  _FIELDS_PERSON ++= _OK
  _FIELDS_BUSINESS ++= _OK


/**
 * Customer
 * --------
 *
 * @class Customer
 * @extends View
 */
class Customer extends App.View

  /** @override */
  _tagName: \form

  /** @override */
  initialize: ({@customer}) ->

  _free: ->
    # TODO(...): Memch for third.
    # @_third._free!
    super!

  /** @override */
  render: ->
    _fields = if @customer.is-business!
              then _FIELDS_BUSINESS
              else _FIELDS_PERSON

    App.builder.Form._new @el, _fields
      # Highlight dynamic field
      for _name in <[money_source reference]>
        .._elements[_name]._field
          ._class += " #{gz.Css \has-error} #{gz.Css \has-feedback}"

      # Business
      if @customer.is-business!
        @_shareholders = .._elements.'shareholders'  # get shareholder
        @_shareholders._field._class = gz.Css \col-md-12

        # TODO: Remove this. Load from constructor. See render on
        #       on shareholders class view.
        _shareholders = @customer._attributes\shareholders
        @_shareholders._view.load-from _shareholders if _shareholders?

        # Ubigeo settings
        b = ..
        .._elements.'ubigeo_department'._element.on-change (evt) ~>
          b._elements.'ubigeo_province'._element
            ..html = ["<option>#{..}</option>" for _._keys App.lists.ubigeo._tree[evt._target._value]]._join ''
            ..\onchange _target: ..

        .._elements.'ubigeo_province'._element.on-change (evt) ~>
          b._elements.'ubigeo_district'._element
            ..html = ["<option>#{..}</option>" for _._keys App.lists.ubigeo._tree[b._elements.'ubigeo_department'._element._value][evt._target._value]]._join ''
            ..\onchange _target: ..

        .._elements.'ubigeo_district'._element.on-change (evt) ~>
          b._elements.'ubigeo'._element._value = App.lists.ubigeo._tree[b._elements.'ubigeo_department'._element._value][b._elements.'ubigeo_province'._element._value][evt._target._value]

        .._elements.'ubigeo_department'._element
          ..\onchange _target: ..

        # Valdity field settings
        .._elements.'customer_type'._element.on-change (evt) ->
          .._elements.'validity'._element._disabled = \
            evt._target._value is \Otros

        # Valdity field settings
        .._elements.'is_obligated'._element
          _obligated-yes = ..query '[value=Sí]'
          _obligated-no = ..query '[value=No]'

        .._elements.'has_officer'._element
          _officer-yes = ..query '[value=Sí]'
          _officer-no = ..query '[value=No]'

        _obligated-no .on-change (evt) ~>
          _officer-yes._disabled = on
          _officer-no._checked = on

        _obligated-yes .on-change (evt) ~>
          _officer-yes._disabled = off


        #TODO: on-change only setting callback. Improve to allow it behaves
        # like onchange.

      # End builder
      ..render!
      .._free!

      #@el.query \select ._selected-index = 4

      ####################
      # TODO: Use memch.
      ####################
      #_third = Third._new!
      _third = new Third
        @el._append ..render!el

    App._form._fromJSON @el, @customer._attributes

    super!


  /** @private */ customer: null
  /** @private */ _third: null
  /** @private */ _shareholders: null


  /** Local variable for settings. */
  _GRID = App.builder.Form._GRID
  _FIELD_ATTR = App.builder.Form._FIELD_ATTR

  /** Field list for person form. (Array.<FieldOptions>) */
  _FIELDS_PERSON_RAW =
    * _name: 'father_name'
      _label: 'a)	Apellido paterno'

    * _name: 'mother_name'
      _label: 'Apellido materno'

    * _name: 'name'
      _label: 'Nombres'

    * _name: 'document[type]'
      _label: 'b)	Tipo documento'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document[number]'
      _label: 'Número documento identidad'

    * _name: 'ruc'
      _label: 'c)	Registro Único de Contribuyentes (RUC), de ser el caso'

    * _name: 'birthplace'
      _label: 'd)	Lugar de nacimiento'

    * _name: 'birthday'
      _label: 'Fecha de nacimiento'

    * _name: 'nationality'
      _label: 'e)	Nacionalidad'

    * _name: 'address'
      _label: 'f)	Domicilio declarado (lugar de residencia)'

    * _name: 'fiscal_address'
      _label: 'g)	Domicilio fiscal, de ser el caso'

    * _name: 'phone'
      _label: 'h)	Número telefono fijo'

    * _name: 'mobile'
      _label: 'Número de celular'

    * _name: 'email'
      _label: 'i)	Correo electrónico'

    * _name: 'activity'
      _label: 'j)	Profesión u ocupación'

    * _name: 'civil_state'
      _label: 'k)	Estado civil'

    * _name: 'partner'
      _label: '1. Nombre del cónyuge o conviviente'

#    * _name: 'partner'
#      _label: '1. Nombre del cónyuge, de ser casado'

#    * _name: ''
#      _label: '2. Si declara conviviente, consignar nombre'

    * _name: 'employment'
      _label: 'j)	Cargo o función pública'

#    * _name: 'money_source'
#      _label: 'm)	El origen de los fondos'
#      _type: FieldType.kComboBox
#      _options: App.lists.money_source._display

    * _name: 'is_obligated'
      _label: 'n)	Si es Sujeto obligado'
      _type: FieldType.kRadioGroup
      _options: <[Sí No]>


  /** Field list for business form. (Array.<FieldOptions>) */
  _FIELDS_BUSINESS_RAW =
    * _name: 'document[type]'
      _label: 'Tipo Documento'
      _type: FieldType.kHidden
      _options: 'RUC'

    * _name: 'name'
      _label: 'a) Razón social'

    * _name: 'document[number]'
      _label: 'b) RUC'

    * _name: 'social_object'
      _label: 'c)	Objeto social'

    * _name: 'activity'
      _label: 'c1) Actividad económica'
#      _type: FieldType.kComboBox
#      _options: App.lists.activity-business._display

    * _name: 'shareholders'
      _label: 'd)	Identificación accionistas'
      _type: FieldType.kView
      _options: new Shareholders

    * _name: 'salesman'
      _label: 'e)	Identificación RL'

    * _name: 'address'
      _label: 'f)	Domicilio'

    * _name: 'fiscal_address'
      _label: 'g)	Domicilio fiscal'

    * _name: 'ubigeo_department'
      _label: 'Departamento'
      _type: FieldType.kComboBox
      _options: App.lists.ubigeo.department._display

    * _name: 'ubigeo_province'
      _label: 'Provincia'
      _type: FieldType.kComboBox
      _options: _._keys App.lists.ubigeo._tree[App.lists.ubigeo.department._display.0]

    * _name: 'ubigeo_district'
      _label: 'Distrito'
      _type: FieldType.kComboBox
      _options: _._keys App.lists.ubigeo._tree[App.lists.ubigeo.department._display.0][_._keys App.lists.ubigeo._tree[App.lists.ubigeo.department._display.0] .0]

    * _name: 'ubigeo'
      _label: 'Código Ubigeo'
      _field-attrs: _FIELD_ATTR._disabled
      _grid: _GRID._inline

    * _name: 'phone'
      _label: 'h)	Teléfono'

    * _name: 'contact'
      _label: 'Persona contacto'

    * _name: 'is_obligated'
      _label: 'j)	Si es Sujeto obligado'
      _type: FieldType.kRadioGroup
      _options: <[Sí No]>

    * _name: 'has_officer'
      _label: 'Oficial cumplimiento'
      _type: FieldType.kRadioGroup
      _options: <[Sí No]>

#    * _name: 'representing_to'
#      _label: 'Representado'
#      _type: FieldType.kComboBox
#      _options:
#        'L (1)'
#        'RL (2)'
#        'Apod (3)'
#        'Mand	(4)'
#        'El mismo'

#    * _name: 'condition'
#      _label: 'Condición'
#      _type: FieldType.kComboBox
#      _options:
#        '(1) Residente'
#        '(2) No Residente'

#    * _name: 'ciiu'
#      _label: 'Codigo CIIU de ocupación'
#      _type: FieldType.kComboBox
#      _options: App.lists.ciiu._display

  /** FIELDS */
  _FIELDS_TOP =
    * _name: 'person_type'
      _label: 'Tipo Persona'
      _type: FieldType.kComboBox
      _grid: _GRID._inline
      _options:
        'Natural'
        'Jurídica'

    * _name: 'customer_type'
      _label: 'Tipo de cliente'
      _type: FieldType.kComboBox
      _options:
        'Importador frecuente'
        'Buen contribuyente'
        'OEA'
        'Otros'

    * _name: 'validity'
      _label: 'Vigencia'

  _FIELDS_BOTTOM =
    * _name: 'money_source'
      _label: 'El origen de los fondos'
      _type: FieldType.kComboBox
      _options: App.lists.money_source._display

    * _name: 'reference'
      _label: 'Ref. Cliente'

  _FIELDS_PERSON = _FIELDS_TOP ++ _FIELDS_PERSON_RAW ++ _FIELDS_BOTTOM
  _FIELDS_BUSINESS = _FIELDS_TOP ++ _FIELDS_BUSINESS_RAW ++ _FIELDS_BOTTOM


/** @export */
module.exports = Customer


# vim: ts=2:sw=2:sts=2:et
