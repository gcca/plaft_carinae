/** @module modules */

panelgroup = require '../../../app/widgets/panelgroup'
  PanelGroup = ..PanelGroup
  PanelHeadingClosable = ..PanelHeadingClosable
  Panel = ..Panel

Declarant = require './declarant'

widget = require '../../../app/widgets/codename'
  InputName = ..InputName
  Search = ..Search


/**
 * PanelHeadingDeclarant
 * ---------------------
 * @class PanelHeadingDeclarant
 * @extends View
 */
class PanelHeadingDeclarant extends PanelHeadingClosable

  /**
   * Modifica el titulo segun el evento on-key-up
   * de cada caja de texto.
   * @param {Integer} _type
   */
  overload-for-title: ->
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
    @set-title "#{dto.'name'}
              \ #{dto.'father_name'}
              \ #{dto.'mother_name'}"


/**
 * PanelDeclarant
 * --------------
 * @class PanelDeclarant
 * @extends Panel
 */
class PanelDeclarant extends Panel

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

  /** @override */
  render: ->
    ret = super!
    @_header.overload-for-title!
    @_header.on (gz.Css \button), @_take-dto
    @render-dto!
    ret

/**
 * Declarants
 * ----------
 * @class Declarants
 * @extends View
 */
class Declarants extends PanelGroup

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
    _head-declarant = new PanelHeadingDeclarant do
      _title: "Declarant"
    _body-declarant = new Declarant do
      dto: null

    @new-panel do
      _panel-heading: _head-declarant, _panel-body: _body-declarant

    _input = App.dom._new \input

    mandar = ~>
      App.ajax._get ('/api/declarant/' + _input._value), null, do
        _success: (declarant-dto) ~>
          _head-declarant.trigger (gz.Css \button), declarant-dto

    _btn = App.dom._new \button
      ..html = "BUSCAR"
      ..on-click mandar

    _head-declarant._add-element _input
    _head-declarant._add-element _btn

  render-dto: (dto) ->
    _head-declarant = new PanelHeadingDeclarant do
      _title: "Declarant"
    _body-declarant = new Declarant do
      dto: dto

    @new-panel do
      _panel-heading: _head-declarant, _panel-body: _body-declarant

  /** @override */
  initialize: ->
    super ConcretPanel: PanelDeclarant

  /** @override */
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
module.exports = Declarants


# vim: ts=2:sw=2:sts=2:et
