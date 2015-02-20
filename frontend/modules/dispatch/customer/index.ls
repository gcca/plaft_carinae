/** @module modules */

Person = require './person'
Business = require './business'

FieldType = App.builtins.Types.Field
DOCUMENT_TYPE_PAIR = App.lists.document-type._pair

/**
 * Third
 * ----------
 * TODO
 *
 * @class Third
 * @extends View
 */
class Third extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \form-group}"

  /*
   * @param {Array.<FieldOptions>} _fields
   * TODO
   * @private
   */
  render-fields: (_fields) ->
    @el._last
      ..html = ''
      App.builder.Form._new .., _fields
        ..render!
        .._free!

  /*
   *
   * TODO
   * @private
   */
  load-person: ~>
    @render-fields _FIELDS_PERSON

  /*
   *
   * TODO
   * @private
   */
  load-business: ~>
    @render-fields _FIELDS_BUSINESS

  /*
   *
   * TODO
   * @public
   */
  no-change: -> @_free!

  /** @override */
  render: ->
    # Highlight dynamic field
    @el.html = "<div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-6}'>
                  <label>Tercero</label>
                  <div></div>
                </div>
                <div></div>"

    radio-person = App.dom._new \input
      .._name = \third_type
      .._type = \radio
      ..on-click @load-person

    radio-business = App.dom._new \input
      .._name = \third_type
      .._type = \radio
      ..on-click @load-business

    @el._first._first._next
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

    * _name: 'ok'
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

    * _name: 'ok'
      _label: 'Persona a favor operacion'
      _type: FieldType.kComboBox
      _options:
        'Importador'
        'Destinatario del embarque'
        'Proveedor'
        'Exportador'

/**
 * Identification
 * ----------
 * TODO
 *
 * @class Identification
 * @extends View
 */
class Identification extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \form-group}"

  /*
   *
   * TODO
   * @private
   */
  load-yes: ~>
    #@third.change-style "display:inline"
    @third = Third._new!
    @el._append @third.render!el

  /*
   *
   * TODO
   * @private
   */
  load-no: ~>
    @third.no-change!

  /** @override */
  render: ->
    @el.html = "<div class='#{gz.Css \form-group}
                          \ #{gz.Css \col-md-6}'>
                  <label>Identificacion del Tercero</label>
                  <div></div>
                </div>"
    radio-yes = App.dom._new \input
      .._name = \identification_type
      .._type = \radio
      ..on-click @load-yes

    radio-no = App.dom._new \input
      .._name = \identification_type
      .._type = \radio
      ..on-click @load-no

    @el._first._first._next
      .._append radio-yes
      .._append App.dom.create-text-node ' Si'
      .._append App.dom._new \span
        ..html = '&nbsp;'*8
      .._append radio-no
      .._append App.dom.create-text-node ' No'

    super!

  /** @private */ third: null

/**
 * Customer
 * ----------
 * TODO
 *
 * @class Customer
 * @extends View
 */
class Customer extends App.View

  /** @override */
  _tagName: \form

  /** @override */
  initialize: ({@_type}) -> super!

  /** @override */
  render: ->
    if @_type is @@Type.kPerson
      @_customer = new Person

    if @_type is @@Type.kBusiness
      @_customer = new Business

    @el._append @_customer.render!.el
    new Identification
      @el._append ..render!.el
    super!

  /** @private */ _type: null
  /** @private */ _customer: null

  @@Type =
    kPerson: 0
    kBusiness: 1

/** @export */
module.exports = Customer


# vim: ts=2:sw=2:sts=2:et
