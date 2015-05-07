/** @module modules */

panelgroup = require '../../../app/widgets/panelgroup'
  PanelGroup = ..PanelGroup
  PanelHeaderClosable = ..PanelHeaderClosable
  Panel = ..Panel

Declarant = require './declarant'

search = require '../widget'
  SearchByDto = ..SearchByDto


/**
 * PanelHeadingDeclarant
 * ---------------------
 * @class PanelHeadingDeclarant
 * @extends View
 */
class PanelHeadingDeclarant extends PanelHeaderClosable

  /**
   * Modifica el titulo segun el evento on-key-up
   * de cada caja de texto.
   * @param {Integer} _type
   */
  overload-for-title: ->
    _name = @_panel.query '[name=name]'
    _father_name = @_panel.query '[name=father_name]'
    _mother_name = @_panel.query '[name=mother_name]'

    /**
     * (Event) Modifica el titulo segun el evento.
     * @private
     * @see parent.set-title
     */
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

  /** @override */
  render: ->
    ret = super!

    _search = new SearchByDto do
      _url: 'declarant'
      _items: window.plaft.'declarant'
      _callback: @_callback-dto

    @_show _search

    ret

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
   * @see @render-dto
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
    for @_panels then .._body.el.query \form ._toJSON!

  /**
   * Mostrar un panel.
   */
  render-panel: ~>
    _head-declarant = new PanelHeadingDeclarant do
      _title: "Declarant"
    _body-declarant = new Declarant do
      dto: null

    @new-panel do
      _panel-heading: _head-declarant, _panel-body: _body-declarant

  /**
   * Carga el panel segun el dto.
   * @param {Array.<dto>} dto
   */
  render-dto: (dto) ->
    _head-declarant = new PanelHeadingDeclarant do
      _title: "Declarant"
    _body-declarant = new Declarant do
      dto: dto

    @new-panel do
      _panel-heading: _head-declarant
      _panel-body: _body-declarant

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
