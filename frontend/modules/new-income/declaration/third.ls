/** @module modules.income */

#############################################################################
# (-o-) TODO: Update class, attributes and methods names.                   #
#############################################################################

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
class Identification extends App.View
  App.mixin.JSONAccessor ::

  /** @override */
  _tagName: \form

  _json-getter: -> @el._toJSON!

  _json-setter: (_dto) ->
    if _dto?
      if _dto.'identification_type'?
        if _dto.'identification_type' is \Si
          @radio-yes._checked = on
          @load-yes!
        else
          @radio-no._checked = on

    @el._fromJSON _dto

  /**
   *
   * @private
   */
  load-yes: ~>
    @third = new Third third: @th
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


/** @export */
module.exports = Identification


# vim: ts=2:sw=2:sts=2:et
