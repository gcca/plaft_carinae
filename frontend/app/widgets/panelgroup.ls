/** @module app.widget */

/**
 * PanelHeading
 * ------------
 *
 * @example
 * >>> panel-heading = new PanelHeading do
 * >>>   _title: 'Example-Title'
 * >>> panel-heading = new PanelHeading
 *
 * @class PanelHeading
 * @extends View
 * @export
 */
class exports.PanelHeading extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \panel-heading}"

  /**
   */
  _callback-dto: (_dto) ~>
    @trigger (gz.Css \button), _dto

  /**
   * Change title
   * @param {String} _title
   */
  set-title: (_title)->
    @el._first._first.html = _title

  /**
   * Remove panel from array-panel
   */
  _remove-panel: ~>
    @trigger (gz.Css \close), @_panel
    $ @_panel .remove!

  /** @override */
  initialize: (@_options) ->
    if @_options?
      @_id-content = @_options._id-content
      @_parent-uid = @_options._parent-uid
      @_title = @_options._title
      @_panel = @_options._panel
    super!

  /** @override */
  render: ->
    @el.css = "padding:5px"
    @el.html = "<div class='#{gz.Css \panel-title}' style='display:flex'>
                  <span data-toggle='collapse'
                     data-parent='##{@_parent-uid}'
                     href='##{@_id-content}'
                     style='margin:5px;width:400px;cursor:pointer'>
                   #{if @_title?
                     then @_title
                     else 'Por defecto'}
                  </span>&nbsp;
                </div>"
    @_head = @el.query ".#{gz.Css \panel-title}"
    super!

  /** @private */ _options: null
  /** @private */ _id-content: null
  /** @private */ _parent-uid: null
  /** @private */ _head: null
  /** @private */ _title: null
  /** @private */ _panel: null



/**
 * PanelHeadingClosable
 * --------------------
 * @example
 * >>> panel-close = new PanelHeaderClosable _title 'Example Title'
 * # Show search.
 * >>> panel-close._show do
 * >>>   _view: view-search [module.income.widget]
 * @class PanelHeadingClosable
 * @extends PanelHeading
 * @export
 */
class exports.PanelHeaderClosable extends PanelHeading

  /**
   * Muestra la seccion search en el panelHeader.
   * @param {view-search} _view
   */
  _show: (_view) ->
    @_search.html = ''
    @_search._append _view.render!.el

  /** @override */
  render: ->
    ret = super!
    @_search = App.dom._new \span
      ..css = "width: 200px;margin: 0;padding: 0;flex:4"

    _btn = App.dom._new \button
        .._class = "#{gz.Css \btn}
                  \ #{gz.Css \btn-sm}
                  \ #{gz.Css \close}
                  \ #{gz.Css \pull-right}"
        ..html = 'x'
        ..on-click @_remove-panel

    _span = App.dom._new \span
      .._class = gz.Css \pull-right
      ..css= "flex:1;margin:5px"
      .._append _btn

    @_head._append @_search
    @_head._append _span
    ret

  /** @private */_search: null

/**
 * PanelHeaderPDF
 * --------------------
 * @example
 * >>> panel-pdf = new PanelHeaderPDF _title 'Example Title'
 * >>> panel-pdf._show do
 * >>>   _href: Refencia del PDF.
 * @class PanelHeaderPDF
 * @extends PanelHeading
 * @export
 */
class exports.PanelHeaderPDF extends PanelHeading

  /**
   * Agrega el boton PDF en el panelHeader.
   * @param {String} _href
   */
  _show: ->
    @_span.html = ''
    _icon = App.dom._new \i
      .._class = "#{gz.Css \glyphicon}
                  \ #{gz.Css \glyphicon-bookmark}"

    _btn = App.dom._new \a
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-info}
                \ #{gz.Css \btn-sm}
                \ #{gz.Css \pull-right}"
      ..href = "#{it._href}"
      ..target = '_blank'
      ..html = 'PDF '
      .._append _icon

    @_span._append _btn
    @_span.css.\display = ''

  /** @override */
  render: ->
    ret = super!

    @_span = App.dom._new \span
      .._class = gz.Css \pull-right
      ..css= "flex:1;margin:5px;display:-webkit-inline-box"

    @_head._append @_span
    ret


/**
 * PanelBody
 * ---------
 *
 * @example
 * >>> panel-body = new PanelBody do
 * >>>   _element: another-view.render!.el
 * >>> panel-body = new PanelBody
 * @class PanelHeading
 * @extends View
 * @export
 */
class exports.PanelBody extends App.View
  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \panel-collapse} #{gz.Css \collapse}"

  /** Obtener el formulario del PanelBody */
  _get-form: ->
    @el.query "#{gz.Css \form}"

  /** @override */
  initialize: (@_options) ->
    if @_options?
      @_id-content = @_options._id-content
      @_element = @_options._element
    super!

  /** @override */
  render: ->
    @el._id = @_id-content
    @el.html="<div class='#{gz.Css \panel-body}'>
              </div>"

    # TODO: Saber si es HTMLElement o String
    if @_element?
      @el._first._append @_element

    super!

  /** @private */ _options: null
  /** @private */ _element: null
  /** @private */ _id-content: null
  /** @private */ _body: null


/**
 * Panel
 * -------------
 * @class Panel
 * @extends View
 * @export
 */
class exports.Panel extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \panel} #{gz.Css \panel-default}"

  /**
   * Open panel.
   */
  _open: ->
    @_collapse._class._add    gz.Css \in

  /**
   * Close panel.
   */
  _close: ->
    @_collapse._class._remove gz.Css \in

  /**
   * Toggle panel to open or close.
   */
  _toggle: ->
    @_collapse._class._toggle gz.Css \in

  /** @override */
  initialize: (@_options) -> super!

  /** @override */
  render: ->
    _id-content = App.utils.uid 'p'

    # building panel heading
    if @_options._panel-heading?
      @_header = @_options._panel-heading
      @_header._id-content = _id-content
      @_header._parent-uid = @_options._parent-uid
      @_header._panel = @el
    else
      @_header = new PanelHeading do
        _title: @_options._title
        _id-panel: _id-content
        _parent-uid: @_options._parent-uid
        _panel: @el

    # building panel body
    if @_options._panel-body?
      @_body = @_options._panel-body
      @_body._id-content = _id-content
    else
      @_body = new PanelBody do
        _id-content: _id-content
        _element: @_options._element

    @el._append @_header.render!.el
    @el._append @_body.render!.el
    @_collapse = @el.query "##{_id-content}"
    @_toggle!


    super!

  /** @private */ _options: null
  /** @public */  _header: null
  /** @public */  _body: null
  /** @private */ _collapse: null


/**
 * PanelGroup
 * ----------
 *
 * @example
 * >>> panel-group = new PanelGroup
 * >>> panel-group.new-panel do
 * ...   _title: 'Example-Title'
 * ...   _element: 'Example contenido' TODO: Falta implementar solo texto.
 * >>> # with panelheading and panelbody
 * >>> panel-heading = new PanelHeading do
 * ...   _title: 'Example-Title'
 * >>> panel-body = new PanelBody do
 * ...   _element: another-view.render!.el
 * >>> panel-group.new-panel do
 * ...   _panel-heading: panel-heading
 * ...   _panel-body: panel-body
 * >>> another-view.el._append panel-group.render!.el
 * >>> # with panelbody
 * >>> _div = App.dom._new \div
 * ...   ..html = 'Example'
 * >>> panel-body = new PanelBody do
 * ...   _element: _div
 * >>> panel-group.new-panel do
 * ...   _title: 'Example Title'
 * ...   _panel-body: panel-body
 * >>> another-view.el._append panel-group.render!.el
 * >>> # with panelheading
 * >>> panel-heading = new PanelHeading do
 * ...   _title: 'Example-Title'
 * >>> panel-group.new-panel do
 * ...   _panel-heading: panel-heading
 * ...   _element: another-view.render!.el
 * >>> another-view.el._append panel-group.render!.el
 *
 * @class PanelGroup
 * @extends View
 * @export
 */
class exports.PanelGroup extends App.View

  /** @override */
  _tagName: \div

  /**
   * Close all panels
   */
  close-all: ->
    for @_panels then .._close!

  /**
   * @see @new-panel
   */
  drop-panel: (panel) ~>
    @_panels._remove panel
    if @_panels._length is 1
      @open-all!

  /**
   * Open all panels
   */
  open-all: ->
    for @_panels then  .._open!

  /**
   * Crea un nuevo panel
   * y lo añade al panel-group.
   * @param {PanelHeading} _panel-heading
   * @param {PanelBody} _panel-body
   * @param {string} _title
   * @param {HTMLElement} _element
   * @return Panel
   */
  new-panel: ({_panel-heading = null,\
               _panel-body = null,\
               _title = null,\
               _element = null} = App._void._Object) ~>
    @close-all!
    _panel = @ConcretPanel._new do
      _title: _title
      _parent-uid: @root-el._id
      _element: _element
      _panel-heading: _panel-heading
      _panel-body: _panel-body
    @root-el._append _panel.render!.el
    _panel._header.on (gz.Css \close), @drop-panel
    @_panels._push _panel
    _panel

  /** @override */
  initialize: ({@root-el = @el, \
                @ConcretPanel = Panel} = App._void._Object) ->
    @_panels = new Array
    super!

  /** @public */ _panels: null

  /**
   * Root for panels accumulation.
   * @type HTMLElement
   * @protected
   */ _root-el: null

  root-el:~
    -> @_root-el
    (el) ->
      @_root-el = el
        .._id = (gz.Css \id-panel-group) + App.utils.uid!
        .._class._add gz.Css \panel-group

  /** @protected */ ConcretPanel: null


# vim: ts=2:sw=2:sts=2:et
