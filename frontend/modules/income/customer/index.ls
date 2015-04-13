/** @module modules */

Person = require './person'
Business = require './business'

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

/**
 * Third
 * ----------
 * @class Third
 * @extends View
 */
class Third extends App.View

  /** @override */
  _tagName: \div

  /**
   * @param {Array.<FieldOptions>} _fields
   * @private
   */
  render-fields: (_fields) ->
    @el._last
      ..html = ''
      App.builder.Form._new .., _fields
        ..render!
        .._free!

  /**
   *
   * @private
   */
  load-person: ~>
    @render-fields _FIELDS_PERSON

  /**
   *
   * @private
   */
  load-business: ~>
    @render-fields _FIELDS_BUSINESS

  /**
   *
   * @public
   */
  no-change: -> @_free!

  /** @override */
  initialize: ({@third}) -> super!

  /** @override */
  render: ->
    @el.html = "<div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-6}'>
                  <label>Tercero</label>
                  <div></div>
                </div>
                <div></div>"

    radio-person = App.dom._new \input
      .._name = \third_type
      .._type = \radio
      ..value = 'Natural'
      ..on-change @load-person

    radio-business = App.dom._new \input
      .._name = \third_type
      .._type = \radio
      ..value = 'Juridico'
      ..on-change @load-business

    @el._first._first._next
      .._append radio-person
      .._append App.dom.create-text-node ' Natural'
      .._append App.dom._new \span
        ..html = '&nbsp;'*8
      .._append radio-business
      .._append App.dom.create-text-node ' Jurídica'

    if @third?
      if @third.'third_type' is \Juridico
        radio-business._checked = on
        @load-business!
      else
        radio-person._checked = on
        @load-person!

    super!


  /** Field list for person form. (Array.<FieldOptions>) */
  _FIELDS_PERSON =
    * _name: 'document_type'
      _label: 'Tipo documento'
      _type: FieldType.kComboBox
      _options: DOCUMENT_TYPE_PAIR

    * _name: 'document_number'
      _label: 'Número documento identidad'

    * _name: 'father_name'
      _label: 'Apellido paterno'

    * _name: 'mother_name'
      _label: 'Apellido materno'

    * _name: 'name'
      _label: 'Nombres'

    * _name: 'third_ok'
      _label: 'Persona a favor operacion'
      _type: FieldType.kComboBox
      _options:
        'Importador'
        'Destinatario del embarque'
        'Proveedor'
        'Exportador'

  /** Field list for business form. (Array.<FieldOptions>) */
  _FIELDS_BUSINESS =
    * _name: 'name'
      _label: 'Razón social'

    * _name: 'third_ok'
      _label: 'Persona a favor operacion'
      _type: FieldType.kComboBox
      _options:
        'Importador'
        'Destinatario del embarque'
        'Proveedor'
        'Exportador'

/**
 * Identification
 * -------------
 *
 * @class Identification
 * @extends View
 */
class exports.Identification extends App.View

  /** @override */
  _tagName: \form

  /**
   *
   * @private
   */
  load-yes: ~>
    @third = Third._new third: @th
    @el._append @third.render!el


  /**
   *
   * @private
   */
  load-no: ~>
    if @third?
      @third.no-change!

  /** @override */
  initialize: ({@th}={}) ->  super!

  /** @override */
  render: ->
    @el.html = "<div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-6}'>
                  <label>Identificacion del Tercero</label>
                  <div></div>
                </div>"
    @radio-yes = App.dom._new \input
      .._name = \identification_type
      .._type = \radio
      ..value = 'Si'
      ..on-change @load-yes

    @radio-no = App.dom._new \input
      .._name = \identification_type
      .._type = \radio
      ..value = 'No'
      ..on-change @load-no

    @el._first._first._next
      .._append @radio-yes
      .._append App.dom.create-text-node ' Si'
      .._append App.dom._new \span
        ..html = '&nbsp;'*8
      .._append @radio-no
      .._append App.dom.create-text-node ' No'

    if @th?
      if @th.'identification_type'?
        if @th.'identification_type' is \Si
          @radio-yes._checked = on
          @load-yes!
        else
          @radio-no._checked = on

    @el._fromJSON @th

    super!

  /** @private */ third: null
  /** @private */ th: null

/**
 * Customer
 * ----------
 *
 * @class Customer
 * @extends View
 */
class exports.Customer extends App.View

  /** @override */
  _tagName: \form

  /** @private */
  on-customer-change: ~>
    @_type = @el.query('[name=customer_type]').selectedIndex
    @el._last.html = ""

    if @_type is @@Type.kPerson
      @_customer = new Person
      @el._append (@_customer).render!.el
      @_third = new Identification
      @el._last._append @_third.render!.el

    if @_type is @@Type.kBusiness
      @_customer = Business._new!
      @el._append (@_customer).render!.el
      @_shareholder = @_customer.shareholder
      @el.query('[name=customer_type]').selectedIndex = @_type
      @_third = new Identification
      @el._last._append @_third.render!.el

    @el.query('[name=customer_type]').selectedIndex = @_type
    @el.query('[name=customer_type]').on-change @on-customer-change

  /** @private */
  set-customer-type: ->
    if _type?
      if @_type is @@Type.kPerson
        @_customer = new Person

      if @_type is @@Type.kBusiness
        @_customer = Business._new!

    else
      if @customer-dto.'document_number'._length is 11
        @_type = @@Type.kBusiness
        @_customer = Business._new!
        @el.query('[name=customer_type]').selectedIndex = @_type
      else
        @_type = @@Type.kPerson
        @_customer = new Person
        @el.query('[name=customer_type]').selectedIndex = @_type

  /**
   * Shareholder list to JSON.
   * @return {Array.<Shareholder-JSON>} || {}
   * @override
   */
  _toJSON: ->
    _r = @el._toJSON!
    if @_type is @@Type.kBusiness
      _r.'shareholders' = @_shareholder._toJSON!
    _r

  /**
   * Carga el dto en el formulario.
   * @private
   */
  render-dto: !->
    @_shareholder = @_customer.shareholder
    if @_shareholder?
      _shareholder = @customer-dto.'shareholders'
      @_shareholder.load-from _shareholder if _shareholder?
    @_third = new Identification th: @third-dto
    @el._last._append @_third.render!.el
    @el.query('[name=customer_type]').on-change @on-customer-change

    @el._fromJSON @customer-dto

  /** @override */
  initialize: ({@customer-dto, @third-dto}) ->  super!

  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELD_HEAD
      ..render!
      .._free!

    @set-customer-type!
    @el._append @_customer.render!.el
    @render-dto!

    super!

  /** @private */ _type: null
  /** @private */ customer-dto: null
  /** @private */ _customer: null
  /** @private */ _shareholder: null
  /** @private */ _third: null

  @@Type =
    kPerson: 0
    kBusiness: 1

  _GRID = App.builder.Form._GRID

  _FIELD_HEAD =
    * _name: 'customer_type'
      _label: 'Tipo Persona'
      _type: FieldType.kComboBox
      _grid: _GRID._inline
      _options: <[Natural Juridico]>

    * _name: 'client_type'
      _label: 'Tipo de cliente'
      _type: FieldType.kComboBox
      _options:
        'Importador frecuente'
        'Buen contribuyente'
        'OEA'
        'Otros'

    * _name: 'validity'
      _label: 'Vigencia'

# vim: ts=2:sw=2:sts=2:et