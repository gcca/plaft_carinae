/** @module modules */

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
   *
   * TODO
   */
  _close: ->
    @_collapse._class._remove gz.Css \in

  # TODO: falta implementar un método {@code open}.

  /**
   *
   * TODO
   */

  _cambio: ->
    _span = App.dom._new \span
    if @_options._span is 1
      _span._class = "#{gz.Css \glyphicon}
                \ #{gz.Css \glyphicon-remove}
                \ #{gz.Css \pull-right}
                \ #{gz.Css \toggle}"
      _span.css = 'margin-top:8px;
                cursor:pointer;
                font-size:18px'
    if @_options._span is 2
      _a = App.dom._new \a
        .._class="#{gz.Css \btn}
                \ #{gz.Css \btn-sm}
                \ #{gz.Css \btn-info}
                \ #{gz.Css \pull-right}"
        ..html = "PDF"
      _span._append _a
    @el._first._append _span

  _toggle: ->
    @_collapse._class._toggle gz.Css \in

  _create_button: ->

  /**
   * @param {Object} options {options.panel} collections.
   * @override
   */
  initialize: (@_options) ->

  /** @override */
  render: ->
    _id-content = App.utils.uid 'p'

    @el.html = "
      <div class='#{gz.Css \panel-heading}'>

      </div>
      <div class='#{gz.Css \panel-collapse} #{gz.Css \collapse} '
           id='#{_id-content}'>
        <div class='#{gz.Css \panel-body}'>
        </div>
      </div>"

    opciones = {_id-content:_id-content,_options-root:@_options,_el-root: @el}

    @_panel-heading = new PanelHeading opciones
    @el._first._append @_panel-heading.render!.el

    @_cambio!
    @_body = @el.query ".#{gz.Css \panel-body}"
    @_header = @el.query ".#{gz.Css \panel-heading}"
    @_collapse = @el.query "##{_id-content}"

    super!

  /** @private */ _options: null
  /** @public */ _body: null
  /** @public */ _header: null
  /** @private */ _collapse: null
  /** @private */ _icon: null
  /** @public */ _panel-heading: null


class PanelHeading extends App.View

  _tagName: \div

  _remove-panel: ~>
    $ @_options._el-root .remove!

  _download-pdf: ->
    console.log 'pdf'

  _create-button-pdf: ~>
    @el.query 'span' .html = ""
    $(@el.query 'span').append "<a class='close-panel btn btn-sm btn-info'>
                                  <i class='glyphicon glyphicon-file'></i>
                                </a>"
    @el.query '.close-panel' .on-click @_download-pdf

  _create-button-close: ~>
    @el.query 'span' .html = ""
    $(@el.query 'span').append "<a class='close-panel btn btn-sm btn-danger'>
                                  <i class='glyphicon glyphicon-remove'></i>
                                </a>"
    @el.query '.close-panel' .on-click @_remove-panel

  ##TODO DEFINIR MEJOR UN NOMBRE PARA ESTA VARIABLE
  _change-button: (create-button) ~>
    switch create-button
      | 0 => @_create-button-pdf!
      | 1 => @_create-button-close!
      | otherwise => console.log 'Sin botones'

  set-title-heading: (title) ~>
    @el._first._first.html = title

  initialize: (@_options) ~>
    @_options-root = @_options._options-root

  render: ->
    @el.html = "<div class='#{gz.Css \panel-title}' style='display:inline'>
                  <a data-toggle='collapse'
                     data-parent='##{@_options-root._parent-uid}'
                     href='##{@_options._id-content}' class='ahref'>
                    #{@_options-root._title}
                  </a>
                  <span class='pull-right btn-group'>
                  </span>
                </div>"

    @_change-button!

    super!

  /** @private */ _options-root: null
  /** @private */ _dynamic-button: null


/**
 * PanelGroup
 * ----------
 * TODO: Descripcion
 *
 * @example
 * >>> panel-group = new PanelGroup
 * >>> panel-group.new-panel 'header' 'body'
 * >>> another-view.el._append panel-group.render!.el
 *
 * @class PanelGroup
 * @extends View
 * @export
 */
class exports.PanelGroup extends App.View

  /** @override */
  _tagName: \div

  /*
   *
   * TODO
   */
  close-all: ->
    for @_panels then  .._close!

  /**
   * Crea un nuevo panel
   * y lo añade al panel-group.
   * @param {string} _title
   * @return Panel
   */
  new-panel: (_title = '')~>
    @close-all!
    @ConcretPanel._new _title: _title, _parent-uid: @root-el._id
        @root-el._append ..render!.el
        @_panels._push ..


  /** @override */
  initialize: ({@root-el = @el, @ConcretPanel = Panel} = {}) ->
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
