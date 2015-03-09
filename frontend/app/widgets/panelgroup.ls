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
  _className: ~>
    "#{gz.Css \panel} #{gz.Css @_panel-color}"

  _set-color-panel: (color) ~>
    @el._class._remove @_panel-color
    @el._class._add color
    @_panel-color = color

  _close: ->
    @_collapse._class._remove gz.Css \in

  _toggle: ->
    @_collapse._class._toggle gz.Css \in

  initialize: (_options) ->
    @_options = _options
    @_parent-uid = _options._parent-uid

  /** @override */
  render: ->
    _id-content = App.utils.uid 'p'

    @el.html = "
      <div class='#{gz.Css \panel-heading}'>

      </div>
      <div class='#{gz.Css \panel-collapse} #{gz.Css \collapse} '
           id='#{_id-content}'>
      </div>"


    @_header = @el.query ".#{gz.Css \panel-heading}"
    @_collapse = @el.query "##{_id-content}"

    opciones = { _parent-uid: @_parent-uid, _id-content: _id-content,_el-root: @el}

    console.log opciones

    @_panel-heading.set-options opciones
    @_header._append @_panel-heading.render!.el
    @el.query "##{_id-content}" ._append @_panel-body.render!.el

    @_set-color-panel 'panel-success'

    super!

  /** @private */   _options: null
  /** @public */    _body: null
  /** @public */    _header: null
  /** @private */   _collapse: null
  /** @protected */ _panel-heading: null
  /** @protected */ _panel-body: null
  /** @public */    _parent-uid: null
  /** @public */    _panel-color: \panel-default


class exports.PanelBody extends App.View

  _tagName: \div

  _className: gz.Css \panel-body

  _get-el: ~>
    @el

  _get-form: ~>
    @el.query 'form'

  _get-body: ~>
    if _.isUndefined @el._first
      console.log 'Existe'
    else
      console.log 'No existe'

  initialize: (@_options) ->
    super!
    @_get-body!

  /** @public */  _form: null
  /** @private */ _options: null


class exports.PanelHeading extends App.View

  _tagName: \div

  _remove-panel: ~>
    $ @_el-root .remove!
    @_panels_aux.trigger 'update-panels-array', "#{@_options._idContent}"

  _set-panels-aux: (panels) ~>
    @_panels_aux = panels

  set-options: (options) ~>
    @_options = options
    @_el-root = @_options._el-root
    @_parent-uid = options._parent-uid

  set-title-heading: (title) ~>
    @el._first._first.html = title

  initialize: (@_options) ->
    super!
    @_options-root = @_options

  render: ->
    @el.html = "<div class='#{gz.Css \panel-title}' style='display:inline'>
                  <a data-toggle='collapse'
                     data-parent='##{@_parent-uid}'
                     href='##{@_options._id-content}' class='ahref'>
                  </a>
                  <span class='pull-right btn-group'>
                  </span>
                </div>"

    super!

  /** @protected */ _el-root: null
  /** @protected */ _panels_aux: null
  /** @protected */ _parent-uid: null


class exports.PanelHeadingClosable extends PanelHeading

  render: ->
    ret = super!

    @el.query '.btn-group'
      $(..).append "<button class='btn btn-sm btn-danger close'>x</button>"
    @el.query '.close' .on-click @_remove-panel

    ret


class exports.PanelHeadingDeclarant extends PanelHeadingClosable

  overload-for-title: ->
    _content-title = @el._first._first
    _name = @_el-root.query '[name=name]'
    _father_name = @_el-root.query '[name=father_name]'
    _mother_name = @_el-root.query '[name=mother_name]'

    _set-title = ~>
      _content-title.html = _name._value + ' ' \
                             + _father_name._value + ' ' \
                             + _mother_name._value

    _name.on-key-up _set-title
    _father_name.on-key-up _set-title
    _mother_name.on-key-up _set-title


class exports.PanelHeadingStakeHolder extends PanelHeadingClosable

  overload-for-title: (_type = @@Type.kBusiness) ->
    @_type = _type

    _content-title = @el._first._first

    if _type is @@Type.kBusiness
      @_el-root.query '[name=name]' .on-key-up (evt) ~>
        _content-title.html = evt._target._value

    if _type is @@Type.kPerson
      _name = @_el-root.query '[name=name]'
      _father_name = @_el-root.query '[name=father_name]'
      _mother_name = @_el-root.query '[name=mother_name]'

      _set-title = ~>
        _content-title.html = _name._value + ' ' \
                            + _father_name._value + ' ' \
                            + _mother_name._value

      _name.on-key-up _set-title
      _father_name.on-key-up _set-title
      _mother_name.on-key-up _set-title

  /** @private */ _type: null
  @@Type =
    kPerson: 0
    kBusiness: 1


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

  _set-array-for-panels: ->
    for @_panels then
      .._panel-heading._set-panels-aux @_panels

  _delete-panel: (id) ~>
    @_panels = _.filter(@_panels, (item) -> item._collapse._id !== id)
    _.extend(@_panels, Backbone.Events);
    _self = @
    @_panels.on \update-panels-array (id) -> _self._delete-panel (id)
    @_set-array-for-panels!

  close-all: ->
    for @_panels then .._close!

  /**
   * Crea un nuevo panel
   * y lo añade al panel-group.
   * @param {string} _title
   * @return Panel
   */

   #cambiarlo tipo-panel a _type
  new-panel: (tipo-panel, tipo-heading, dto = null) ~>
    @close-all!
    @ConcretPanel._new _parent-uid: @root-el._id
        .._panel-body = tipo-panel
        .._panel-heading = tipo-heading
        @root-el._append ..render!.el
        @_panels._push ..

  /** @override */
  initialize: ({@root-el = @el, @ConcretPanel = Panel} = {}) ->
    @_panels = new Array
    _.extend(@_panels, Backbone.Events);
    _self = @
    @_panels.on \update-panels-array (id) -> _self._delete-panel (id)
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
