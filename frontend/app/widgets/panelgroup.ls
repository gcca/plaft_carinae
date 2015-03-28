/** @module modules */

/**
 * PanelHeading
 * ------------
 *
 * @example
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 * >>> panel-heading = new PanelHeading do
 * >>>  _title: 'Example-Title'
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 * >>> panel-heading = new PanelHeading
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
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
   * Change title
   * @param {String} _title
   */
  set-title: (_title)->
    @el._first._first.html = _title

  /**
   * Remove panel from array-panel
   */
  _remove-panel: ~>
    $ @_panel .remove!
    @_array-panels.trigger (gz.Css \button), "#{@_id-panel}"

  /**
   * Setea el valor del array-panel en cada panel-heading
   * @param {Array.<Panel>} panels
   */
  _set-panels: (panels) ~>
    @_array-panels = panels

  /**
   * TODO
   */
  _add-element: (_element) ->
    _title = @el._first._first
    _element.css = "margin-left:40px;"
    @_btn-group._append _element

  /**
   * Cambia el modelo de vista del panel-heading
   * @param {String} _type
   * @param {String} _href if _type is PDF
   */
  _change-type: (_type, _href="") ->
    @_btn-group.html = ''
    if _type is \pdf
      _icon = App.dom._new \i
        .._class = "#{gz.Css \glyphicon}
                  \ #{gz.Css \glyphicon-bookmark}"
      _btn = App.dom._new \a
        .._class = "#{gz.Css \btn}
                  \ #{gz.Css \btn-info}
                  \ #{gz.Css \btn-sm}
                  \ #{gz.Css \pull-right}"
        ..href = "api/pdf/#{_href}"
        ..css = "margin-left:40px"
        ..target = '_blank'
        ..html = 'PDF '
        .._append _icon
      @_btn-group._append _btn
    if _type is \close
      _btn = App.dom._new \button
        .._class = "btn btn-sm close"
        ..css = "margin-left:40px"
        ..html = 'x'
        ..on-click @_remove-panel
      @_btn-group._append _btn


  /** @override */
  initialize: (@_options) ->
    if @_options?
      @_id-panel = @_options._id-panel
      @_parent-uid = @_options._parent-uid
      @_title = @_options._title
      @_type = @_options._type
      @_panel = @_options._panel
    super!

  /** @override */
  render: ->
    @el.html = "<div class='#{gz.Css \panel-title}' style='display:inline'>
                  <a data-toggle='collapse'
                     data-parent='##{@_parent-uid}'
                     href='##{@_id-panel}'>
                   #{if @_title?
                     then @_title
                     else 'Por defecto'}
                  </a>
                  <span class='#{gz.Css \pull-right}' style='width:600px'>
                  </span>
                </div>"
    @_btn-group =@el.query '.pull-right'
    if @_type?
      @_change-type @_type
    super!

  /** @private */ _options: null
  /** @private */ _id-panel: null
  /** @private */ _parent-uid: null
  /** @private */ _title: null
  /** @private */ _type: null
  /** @private */ _panel: null
  /** @private */ _array-panels: null


/**
 * PanelHeadingClosable
 * --------------------
 *
 * @class PanelHeadingClosable
 * @extends PanelHeading
 * @export
 */

class exports.PanelHeadingClosable extends PanelHeading

  /** @override */
  render: ->
    ret = super!
    @_change-type \close
    ret

/**
 * PanelBody
 * ---------
 *
 * @example
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 * >>> panel-body = new PanelBody do
 * >>>  _element: another-view.render!.el
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 * >>> panel-body = new PanelBody
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
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
    @el.query 'form'

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

#   TODO: Saber si es HTMLElement o String
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
 * TODO: Descripcion
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
   * Open panel
   */
  _open: ->
    @_collapse._class._add    gz.Css \in

  /**
   * Close panel
   */
  _close: ->
    @_collapse._class._remove gz.Css \in

  /**
   * Change class for panel
   */
  _toggle: ->
    @_collapse._class._toggle gz.Css \in

  /** @override */
  initialize: (@_options) -> super!

  /** @override */
  render: ->
    _id-content = App.utils.uid 'p'

#    BUILD PANEL-HEADING
    if @_options._panel-heading?
      @_header = @_options._panel-heading
      @_header._id-panel = _id-content
      @_header._parent-uid = @_options._parent-uid
      @_header._panel = @el
    else
      @_header = new PanelHeading do
        _title: @_options._title
        _id-panel: _id-content
        _parent-uid: @_options._parent-uid
        _panel: @el

#    BUILD PANEL-BODY
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
 * TODO: Descripcion
 *
 * @example
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 * >>> panel-group = new PanelGroup
 * >>> panel-group.new-panel do
 * >>>  _title: 'Example-Title'
 * >>>  _element: [HTMLElement || String]
 * >>> another-view.el._append panel-group.render!.el
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 * >>> panel-heading = new PanelHeading || new PanelHeadingClosable do
 * >>>     _title: 'Example-Title'
 * >>> panel-body = new PanelBody do
 * >>>     _element: [HTMLElement || String]
 * >>> panel-group = new PanelGroup
 * >>> panel-group.new-panel do
 * >>>  _panel-heading: panel-heading
 * >>>  _panel-body: panel-body
 * >>> another-view.el._append panel-group.render!.el
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
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
   * Open all panels
   */
  open-all: ->
    for @_panels then  .._open!

  /**
   * Envia el arreglo de paneles a la cabecera.
   */
  _array-panels: ->
    for @_panels then
      .._header._set-panels @_panels

  /**
   * Elimina un panel de arreglo de paneles.
   */
  _delete-panel: (id) ~>
    @_panels = _.filter(@_panels, (item) -> item._collapse._id !== id)
    _.extend(@_panels, Backbone.Events);
    _self = @
    @_panels.on (gz.Css \button), (id) -> _self._delete-panel id
    @_array-panels!

  /**
   * Crea un nuevo panel
   * y lo añade al panel-group.
   * @param {PanelHeading} _panel-heading
   * @param {PanelBody} _panel-body
   * @param {string} _title
   * @param {HTMLElement} _element
   * @return Panel
   */
   #cambiarlo tipo-panel a _type
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
    @_panels._push _panel
    @_array-panels!

  /** @override */
  initialize: ({@root-el = @el, \
                @ConcretPanel = Panel} = App._void._Object) ->
    @_panels = new Array
    _.extend(@_panels, Backbone.Events);
    _self = @
    @_panels.on (gz.Css \update), (id) -> _self._delete-panel (id)
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
