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
    $ @_panel .remove!
    @_array-panels.trigger (gz.Css \close), @_id-panel

  /**
   * Setea el valor del array-panel en cada panel-heading
   * @param {Array.<Panel>} panels
   */
  _set-panels: (panels) ~>
    @_array-panels = panels

  /**
   * Cambia el modelo de vista del panel-heading
   * @param {String} _type
   * @param {String} _href if _type is PDF
   */
  _change-type: ->
    if not it._span?
      it._span = App.dom._new \span
        .._class = gz.Css \pull-right
        ..css= "flex:1;margin:3px"
      @_head._append it._span

    # TODO: Quitar esto. La idea es aplicar la herencia para decidir
    #       qué construir.
    switch it._type
    | @@kPDF =>
      it._span.html = ''
      _icon = App.dom._new \i
        .._class = "#{gz.Css \glyphicon}
                  \ #{gz.Css \glyphicon-bookmark}"
      _btn = App.dom._new \a
        .._class = "#{gz.Css \btn}
                  \ #{gz.Css \btn-info}
                  \ #{gz.Css \btn-sm}
                  \ #{gz.Css \pull-right}"
        ..href = "api/pdf/#{it._href}"
        ..target = '_blank'
        ..html = 'PDF '
        .._append _icon

      it._span._append _btn
    | @@kClose =>
      _btn = App.dom._new \button
        .._class = "#{gz.Css \btn}
                  \ #{gz.Css \btn-sm}
                  \ #{gz.Css \close}
                  \ #{gz.Css \pull-right}"
        ..html = 'x'
        ..on-click @_remove-panel
      it._span._append _btn

  /** @override */
  initialize: (@_options) ->
    if @_options?
      @_id-panel = @_options._id-panel
      @_parent-uid = @_options._parent-uid
      @_title = @_options._title
      @_panel = @_options._panel
    super!

  /** @override */
  render: ->
    @el.css = "padding:5px"
    @el.html = "<div class='#{gz.Css \panel-title}' style='display:flex'>
                  <a data-toggle='collapse'
                     data-parent='##{@_parent-uid}'
                     href='##{@_id-panel}'
                     style='margin:5px;width:400px;'>
                   #{if @_title?
                     then @_title
                     else 'Por defecto'}
                  </a>&nbsp;
                </div>"
    @_head = @el.query ".#{gz.Css \panel-title}"
    super!

  /** @private */ _options: null
  /** @private */ _id-panel: null
  /** @private */ _parent-uid: null
  /** @private */ _head: null
  /** @private */ _title: null
  /** @private */ _panel: null
  /** @private */ _array-panels: null

  # TODO: Quitar los enums del prototype.
  #       No es necesario que esté en prototype.
  #       En el caso de Notifier se justifica por no ser más compleja
  #       y facilitar, por ello, el acceso a los enums. Acá no sucede
  #       lo mismo. Además, Notifier es un singleton.
  kPDF   : @@kPDF    = 1
  kClose : @@kClose  = 2


/**
 * PanelHeadingClosable
 * --------------------
 *
 * TODO(Javier): Falta ejemplo.
 * @class PanelHeadingClosable
 * @extends PanelHeading
 * @export
 */
class exports.PanelHeaderClosable extends PanelHeading

  /** @override */
  render: ->
    ret = super!
    @_search = App.dom._new \span
      ..css = "width: 200px;margin: 0;padding: 0;flex:4"

    _span = App.dom._new \span
      .._class = gz.Css \pull-right
      ..css= "flex:1;margin:5px"
    @_change-type do
      _type: @kClose
      _span: _span
    @_head._append @_search
    @_head._append _span
    ret
  /** @private */_search: null


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
      @_header._id-panel = _id-content
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
 * TODO(Javier): Mejorar el ejemplo. En los ejemplos se deben usar casos
 *               concretos. Si el panel-group puede recibir en el atributo
 *               "_element: [HTMLElement || String]", se debe desarrollar
 *               ambos casos en el ejemplo, es decir, es código que se
 *               escribiría si _element fuera un HTMLElement o si fuera un
 *               string. De manera similar con el resto de casos.
 * >>> panel-group = new PanelGroup
 * >>> panel-group.new-panel do
 * >>>   _title: 'Example-Title'
 * >>>   _element: [HTMLElement || String]
 * >>> another-view.el._append panel-group.render!.el
 * >>> # with panelheading and panelbody
 * >>> panel-heading = new PanelHeading || new PanelHeadingClosable do
 * >>>   _title: 'Example-Title'
 * >>> panel-body = new PanelBody do
 * >>>   _element: [HTMLElement || String]
 * >>> panel-group = new PanelGroup
 * >>> panel-group.new-panel do
 * >>>   _panel-heading: panel-heading
 * >>>   _panel-body: panel-body
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
    @_panels = [pl for pl in @_panels when pl._collapse._id !== id]
    _.extend(@_panels, App.Events)
    @_panels.on (gz.Css \close), @_delete-panel
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
  # TODO: Quitar el valor por defecto de ConcretPanel a Panel.
  #       En caso de una clase hija de HijaPanelGroup con su "propio"
  #       HijaPanel, siempre estaría recibiendo la clase Panel.
  #       Lo idel es que se pueda definir la clase HijaPanel por defecto,
  #       de ser lo que se desea.
  initialize: ({@root-el = @el, \
                @ConcretPanel = Panel} = App._void._Object) ->
    @_panels = new Array
    _.extend(@_panels, App.Events);
    @_panels.on (gz.Css \close), @_delete-panel
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
