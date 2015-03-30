/** @module modules */

panelgroup = require '../../../app/widgets/panelgroup'
  PanelGroup = ..PanelGroup
  PanelHeadingClosable = ..PanelHeadingClosable
  Panel = ..Panel

operation-widgets = require '../widget'
  DTOPanelGroup = ..DTOPanelGroup
Stakeholder = require './stakeholder'

widget = require '../../../app/widgets/codename'
  InputName = ..InputName

/**
 * PanelHeadingStakeholder
 * ---------------------
 * @class PanelHeadingStakeholder
 * @extends PanelHeadingClosable
 */
class PanelHeadingStakeholder extends PanelHeadingClosable

  /**
   * Modifica el titulo segun el evento on-key-up
   * de cada caja de texto.
   * @param {Integer} _type
   */
  overload-for-title: (_type = @@Type.kBusiness) ->
    @_type = _type

    if _type is @@Type.kBusiness
      @_panel.query '[name=name]' .on-key-up (evt) ~>
        @set-title evt._target._value

    if _type is @@Type.kPerson
      _name = @_panel.query '[name=name]'
      _father_name = @_panel.query '[name=father_name]'
      _mother_name = @_panel.query '[name=mother_name]'

      _set-title = ~>
        @set-title _name._value + ' ' \
                            + _father_name._value + ' ' \
                            + _mother_name._value

      _name.on-key-up _set-title
      _father_name.on-key-up _set-title
      _mother_name.on-key-up _set-title

  /**
   * Cambia el titulo del Panel-heading.
   * @param {Object} dto
   */
  load-title: (dto) ->
    if dto.'customer_type' is \Natural
      @set-title "#{dto.'name'}
                \ #{dto.'father_name'}
                \ #{dto.'mother_name'}"
    else
      @set-title "#{dto.'name'}"

  /** @private */ _type: null

  /**
   * Opciones de Tipo de Persona
   */
  @@Type =
    kPerson: 0
    kBusiness: 1

/**
 * PanelStakeholder
 * ---------------------
 * @class PanelStakeholder
 * @extends Panel
 */
class PanelStakeholder extends Panel

  /**
   * Modifica el titulo segun el dto.
   */
  render-dto: ->
    _dto = @_body._options.dto
    if _dto?
      @_header.load-title _dto

  /**
   * Carga el dto en el formulario actual.
   */
  _take-dto: ~>
    @_body._options.dto = it
    @_body.read-dto it
    @render-dto!

  /**
   * @param {Event} it
   * Cambia el titulo de la cabecera.
   */
  _load-title: ~>
    @_header.overload-for-title it

  /** @override */
  render: ->
    ret = super!
    _type = @_body.el.query '[name=customer_type]'
    if _type._value is \Natural
      TYPE = 0
    else
      TYPE = 1

    @_header.overload-for-title TYPE

    @_body.on (gz.Css \change), @_load-title

    @_header.on (gz.Css \button), @_take-dto

    @render-dto!
    ret

/**
 * Stakeholders
 * ----------
 * @class Stakeholders
 * @extends PanelGroup
 */
class Stakeholders extends PanelGroup

  /** @override */
  _tagName: \div

  /**
   * Form to JSON.
   * @return {Object}
   * @private
   */
  _toJSON: ->
    for @_panels then .._body._get-form!._toJSON!

  render-panel: ~>
    _head-stakeholder = new PanelHeadingStakeholder do
      _title: "Vinculado"
    _body-stakeholder = new Stakeholder do
      dto: null

    @new-panel do
      _panel-heading: _head-stakeholder, _panel-body: _body-stakeholder

    _input = App.dom._new \input

    mandar = ~>
      App.ajax._get ('/api/linked/' + _input._value), null, do
        _success: (linked-dto) ~>
          _head-stakeholder.trigger (gz.Css \button), linked-dto

    _btn = App.dom._new \button
      ..html = "BUSCAR"
      ..on-click mandar

    _head-stakeholder._add-element _input
    _head-stakeholder._add-element _btn

  render-dto: (dto) ->
    _head-stakeholder = new PanelHeadingStakeholder do
      _title: "Vinculado"
    _body-stakeholder = new Stakeholder do
      dto: dto

    @new-panel do
      _panel-heading: _head-stakeholder, _panel-body: _body-stakeholder

  /** @override */
  initialize: ->
    super ConcretPanel: PanelStakeholder

  /**
   * @override
   */
  render: ->
    @$el.removeAttr('class')
    @$el.removeAttr('id')

    @el.html = "<div></div>
                <button type='button'
                        class= '#{gz.Css \btn}
                              \ #{gz.Css \btn-default}'>
                  Agregar
                </button>"
    @root-el = @el._first
    @el._last.on-click @render-panel

    if @collection?
      if @collection._length isnt 0
        for _dto in @collection
          @render-dto _dto

    super!

/** @export */
module.exports = Stakeholders


# vim: ts=2:sw=2:sts=2:et
