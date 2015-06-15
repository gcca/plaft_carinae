/** @module app.widget */

class ControlBar extends App.View

  @@__hash__ = 'progressbar'

  _tagName: \div

  _className: gz.Css \progress

  _set-bar: (_ratio) ->
    @el.css\display = \block
    @_div
      ..html = "#{_ratio}%"
      ..css = "width:#{_ratio}%"

  initialize: ({heading}) ->
    @el.css = 'width:150px;margin:5px;background-color:white;display:none'
    @_div = App.dom._new \div
      .._class = "#{gz.Css \progress-bar}"
      ..rol = 'progressbar'
      ..attr 'aria-valuenow', '0'
      ..attr 'aria-valuemin', '0'
      ..attr 'aria-valuemax', '100'
    @el._append @_div

  /** @private */ _div: null

class ControlTitle extends App.View

  @@__hash__ = 'title'

  _tagName: \span

  _text:~
    -> @el.html
    (title) ->
      @el.html = title

  initialize: ({_heading}) ->
    @el.css = 'margin:5px;width:400px;cursor:pointer'
    @el.html = '&nbsp;'*8
    @el._data.'toggle' = 'collapse'
    @el._data.'parent' = "##{_heading._parent-uid}"
    @el.attr \href "##{_heading._collapse-id}"
    @el.attr \aria-expanded \false


class ControlClose extends App.View

  @@__hash__ = 'close'

  _tagName: \span

  _className: gz.Css \pull-right

  on-close: ~> @_heading._panel._free!

  initialize: ({@_heading}) ->
    @el.css = 'flex:1;margin:5px'
    _btn = App.dom._new \button
        .._class = "#{gz.Css \btn}
                  \ #{gz.Css \btn-sm}
                  \ #{gz.Css \close}
                  \ #{gz.Css \pull-right}"
        ..html = '&times;'
        ..on-click @on-close
    @el._append _btn

  _heading: null


class ControlSearch extends App.View

  @@__hash__ = 'search'

  _tagName: \span

  _apply-attr: (_url, _items) ->
    @_url = _url
    @_items = _items
    (new App.widget.Typeahead do
      el: @_input
      _source:
        _display: App.widget.Typeahead.Source.kDisplay
        _tokens: App.widget.Typeahead.Source.kTokens
      _limit: 3
      _collection: [{
        _name: n, \
        _code: '<span style="color:#555;font-size:9px">...</span>', \
        _id: @_items[n], \
        _display: n, \
        _tokens: n} \
        for n of @_items]
      _template: (p) -> "
        <p style='float:right;font-style:italic;margin-left:1em'>
          #{p._code}</p>
        <p style='font-size:14px;text-align:justify'>#{p._name}</p>")
      ..on-closed @changeValue _, @_heading
      ..render!

  changeValue: (_, _heading) ~>
    @_value = @_items[@_input._value]
    @load-dto _heading

  load-dto: (_heading) ->
    App.ajax._get ("/api/#{@_url}/" + @_value), null, do
      _success: (_dto) ~>
        _heading._panel.trigger (gz.Css \load-body), _dto

  _search-dto: (_, _heading) ~>
    @load-dto _heading

  initialize: ({@_heading}) ->
    @el.css = 'width: 200px;margin: 0;padding: 0;flex:4'

    @_search = App.dom._new \div
      .._class = gz.Css \input-group
    @_search.html = ''
    @_input = App.dom._new \input
      .._type = \text
      .._name = \search
      .._class = gz.Css \form-control
    @_search._append @_input

    _button = App.dom._new \button
      .._class = "#{gz.Css \btn} #{gz.Css \btn-default}"
      ..html = "&nbsp;<i class='#{gz.Css \glyphicon}
                              \ #{gz.Css \glyphicon-search}'></i>&nbsp;"
      ..on-click @_search-dto _, @_heading

    _span = App.dom._new \span
        .._class = gz.Css \input-group-btn
        .._append _button

    @_search._append _span
    @el._append @_search

  /** @private */ _field   : null
  /** @private */ _name    : null
  /** @private */ _input   : null
  /** @private */ _heading   : null
  /** @private */ _value  : null


class PanelHeading extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \panel-heading}"


  /** @override */
  initialize: ({@_parent-uid, @_panel, @_collapse-id}) ->
    super!
    @_control = {}
    @el.css = "padding:5px"
    @el.html = "<div class='#{gz.Css \panel-title}' style='display:flex'>
                </div>"
    @_container = @el._first
    for control in @_controls
      _instance = new control do
        _heading: @
      @_container._append _instance.render!.el
      @_control[control.__hash__] = _instance

  _get: (_Control) ->
    @_control[_Control.__hash__]


  /** @private */ _parent-uid: null
  /** @private */ _container: null
  /** @private */ _title: null
  /** @private */ _panel: null
  /** @protected */ _controls: [ControlTitle]
  /** @private */ _control: null
  /** @private */ _collapse-id: null


class PanelBody extends App.View

  _tagName: \div

  _className: gz.Css \panel-body

  initialize: ({@_panel}) -> super!

  _panel: null


class JSONBody extends PanelBody

  _json:~
    -> @_json-getter!
    (_dto) ->
      @_json-setter _dto

  _json-getter: ->

  _json-setter: (_dto) ->


class FormBody extends JSONBody

  _tagName: \form

  _json-getter: -> @el._toJSON!

  _json-setter: (_dto) ->
    @el._fromJSON _dto


class Panel extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \panel} #{gz.Css \panel-default}"

  /** @override */
  _free: ->
    #@trigger (gz.Css \free), @
    @_panel-group.drop-panel @
    @_header._free!
    @_body._free!
    super!

  _open: -> @_collapse._class._add    gz.Css \in

  _close: -> @_collapse._class._remove gz.Css \in

  _toggle: -> @_collapse._class._toggle gz.Css \in

  /** @override */
  initialize: ({_heading=PanelHeading, \
                _body=PanelBody, \
                @_parent-uid, \
                @_panel-group}) ->
    @_collapse-id = App.utils.uid 'p'

    @_header = _heading._new do
      _parent-uid: @_parent-uid
      _panel: @
      _collapse-id: @_collapse-id
    @_body = _body._new _panel: @
    super!

  /** @override */
  render: ->
    @el._append @_header.render!.el

    @_collapse = App.dom._new \div
      .._class = "#{gz.Css \panel-collapse}
                \ #{gz.Css \collapse}"
      .._id = @_collapse-id

    @_collapse._append @_body.render!.el

    @el._append @_collapse
    super!

  /** @public */  _header: null
  /** @public */  _body: null
  _collapse-id: null
  _collapse: null


class PanelGroup extends App.View

  /** @override */
  _tagName: \div

  close-all: -> for @_panels then .._close!

  open-all: -> for @_panels then  .._open!

  /** @see @new-panel */
  drop-panel: (panel) ~>
    @_panels._remove panel

  /**
   * Crea un nuevo panel
   * y lo añade al panel-group.
   * @param {PanelHeading} _panel-heading
   * @param {PanelBody} _panel-body
   * @param {string} _title
   * @param {HTMLElement} _element
   * @return Panel
   */
  new-panel: ({_panel-heading = PanelHeading,\
               _panel-body = PanelBody} = {}) ~>
    @close-all!
    _panel = @_Panel._new do
      _parent-uid: @__container._id
      _heading: _panel-heading
      _body: _panel-body
      _panel-group: @

    @__container._append _panel.render!.el
    # _panel.on (gz.Css \free), @drop-panel
    @_panels._push _panel
    _panel._open!
    _panel

  /** @override */
  initialize: ({@_container = @el, \
                @_Panel = Panel} = App._void._Object) ->
    @_panels = new Array
    super!

  /** @public */ _panels: null

  /**
   * Root for panels accumulation.
   * @type HTMLElement
   * @protected
   */ __container:  # dummy
     _id: null
     _class: _remove: ->

  _container:~
    -> @__container
    (el) ->
      @__container
        .._id = ''
        .._class._remove gz.Css \panel-group

      @__container = el
        .._id = (gz.Css \id-panel-group) + App.utils.uid!
        .._class._add gz.Css \panel-group

  /** @protected */ Panel: null

/** @export */
exports <<<
  PanelGroup: PanelGroup
  PanelBody: PanelBody
  PanelHeading: PanelHeading
  ControlTitle: ControlTitle
  ControlClose: ControlClose
  ControlSearch: ControlSearch
  ControlBar: ControlBar
  FormBody: FormBody
  JSONBody: JSONBody

# vim: ts=2:sw=2:sts=2:et
