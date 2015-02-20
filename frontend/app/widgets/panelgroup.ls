/** @module modules */


/**
 * Panel
 * -------------
 * TODO: Descripcion
 * @class Panel
 * @extends View
 */
class Panel extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \panel} #{gz.Css \panel-default}"

  /*
   *
   * TODO
   */
  _close: ->
    @_collapse._class._remove gz.Css \in

  # TODO: falta implementar un método {@code open}.

  /*
   *
   * TODO
   */
  _toggle: ->
    @_collapse._class._toggle gz.Css \in

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
        <h4 class='#{gz.Css \panel-title}' style='display:inline'>
          <a data-toggle='collapse'
             data-parent='##{@_options._parent-uid}'
             href='##{_id-content}' class='ahref'>
             #{@_options._title}
          </a>
          <span id='sc' class='#{gz.Css \glyphicon}
                     \ #{gz.Css \glyphicon-plus}
                     \ #{gz.Css \pull-right}'>
          </span>
        </h4>
      </div>
      <div class='#{gz.Css \panel-collapse} #{gz.Css \collapse} '
           id='#{_id-content}'>
        <div class='#{gz.Css \panel-body}'>
            #{@_options._content}
        </div>
      </div>"
    @_body = @el.query ".#{gz.Css \panel-body}"
    @_header = @el.query ".#{gz.Css \panel-heading}"
    @_collapse = @el.query "##{_id-content}"
    @_icon = @el.query '#sc'
    @el.query ".ahref" .on-click (evt) ~>
      @_icon._class._toggle gz.Css \glyphicon-plus
      @_icon._class._toggle gz.Css \glyphicon-minus

    super!

  /** @private */ _options: null
  /** @public */ _body: null
  /** @public */ _header: null
  /** @private */ _collapse: null
  /** @private */ _icon: null


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
 */
class PanelGroup extends App.View

  /** @override */
  _tagName: \div
  /** @override */
#  _id: gz.Css \id-panel-group

  /** @override */
  _className: gz.Css \panel-group

  /*
   *
   * TODO
   */
  close-all: -> for @_panels then  .._close!

  /**
   * Crea un nuevo panel
   * y lo añade al panel-group.
   * @param {string} _title
   * @param {?(string|HTMLElement)} _content
   * @return Panel
   */
  new-panel: (_title, _content = '') ->
    new Panel _title: _title, _content: _content, _parent-uid: @_uid
      @el._append ..render!.el
      @_panels._push ..

  /** @override */
  initialize: ->
    @_panels = new Array
    @el._id = @_uid = (gz.Css \id-panel-group) + App.utils.uid!

  /** @private */ _uid: null
  /** @public */ _panels: null

/** @export */
module.exports = PanelGroup


# vim: ts=2:sw=2:sts=2:et
