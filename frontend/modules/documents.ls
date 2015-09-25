/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../workspace/module'


class Treeview extends App.View

  /** @override */
  _tagName: \ul

  /**
   * (Un) collapse list.
   */
  _toggle: !-> @$el._toggle!

  _show: !-> @$el._show!

  _hide: !-> @$el._hide!

  __UL_TYPES =
      gz.Css \circle
      gz.Css \square

  /**
   * Generate tree from data.
   * @param {Array<String|Array<...>>} _tree
   */
  render: (_tree = new Array, _global, _level = 0) ->  # HARDCODE: level
    _global = @ if not _global  # TODO: Remove this!!
    @el.html = null
    if _tree and _tree._constructor is Array
      for _node in _tree
        App.dom._new \li
          ..css.'cursor' = 'pointer'
          ..html = _node.0
          @el._append ..

          if _node.1  # Is there something?
            if _node.1._constructor is Array  # subtree
              tv = new Treeview
              # HARDCODE: level
              @el._append (tv.render _node.1, _global, (_level + 1)).el

              # TODO: On toggle method for treeview.
              ((tv) -> ..on-click ~> tv._toggle!) tv

              # HARDCODE: level
              ..css.'list-style-type' = __UL_TYPES[_level % 2]

              # HARDCODE: collapse
              tv._hide!

            if _node.1._constructor is Number  # leaf
              ((_node) -> ..on-click ~>
                _global.trigger (gz.Css \leaf-click), _node.1) _node

              # HARDCODE: level
              ..css.'list-style-type' = gz.Css \disc

    # ------------------------
    # What if `_tree` is null?
    # ------------------------
    # @_hide!  # TODO: collapse by default
    super!


class Documents extends Module

  /**
   * Add options from buttons or inputs.
   * @private
   */
  render-controls: !->
    App.dom._new \div
      .._class = gz.Css \col-md-12
      ..css = 'margin-bottom:2em'
      ..html = "
        <button class='#{gz.Css \btn} #{gz.Css \btn-primary}'>
          Agregar documento
        </button>
        &nbsp;&nbsp;&nbsp;&nbsp;
        <button class='#{gz.Css \btn} #{gz.Css \btn-info}'>
          Maximizar
        </button>
        &nbsp;&nbsp;&nbsp;&nbsp;
        <button class='#{gz.Css \btn} #{gz.Css \btn-success}'>
          PDF
        </button>
      "

      .._first.on-click @add-document
      .._first._next.on-click @maximize-viewer
      .._first._next._next.on-click @pdf-modal

      @el._append ..

  pdf-modal: ~>
    _modal = new App.widget.message-box.Modal do
      _title: 'Fuente PDF'
      _body: "<iframe src='/api/document/#{@_current-node}/getsource'
                      style='width:100%;
                             height:100%'>"
    _modal._body.style.'padding' = '0'
    _modal._show App.widget.message-box.Modal.CLASS.large

  maximize-viewer: ~>
    if @_viewer.class-name is gz.Css \col-md-12
      $ @treeview-container ._show!
      @_viewer.class-name = gz.Css \col-md-8
    else
      $ @treeview-container ._hide!
      @_viewer.class-name = gz.Css \col-md-12

  __func = (_body, _level, _id, _callback) ->
    App.ajax._get "/api/document/#_id", null, do
      _success: (_list) ->
        _select = App.dom._new \select
          .._class = "#{gz.Css \form-control}
                    \ #{gz.Css \col-md-12}"
          ..css = "float:none;
                   padding-left:#{_level}em"
          ..html = '<option value="0"></option>'

          ..on-change (evt) ->
            _target = evt._target

            _tmp = new Array
            _iter = _target._next
            while _iter
              _tmp._push _iter
              _iter = _iter._next

            for _el in _tmp
              _body._remove _el

            _id = _target._value
            if _id isnt '0'
              __func _body, (_level + 1), _id, ->  # _body._append _select

        for _pair in _list
          App.dom._new \option
            .._value = _pair.1
            ..html = _pair.0
            _select._append ..

        _body._append _select  # see callback

        _callback!
      _error: -> alert 'Loop'

  add-document: ~>
    _body = App.dom._new \div
    _file = App.dom._new \form
      ..css = 'margin-bottom:-1em;
               margin-top:2em'
      ..'action' = '/api/document'
      ..'method' = 'post'
      ..html = "
        <div class='#{gz.Css \form-group}'>
          <label for='tita'>Título</label>
          <input type='text' id='tita' class='#{gz.Css \form-control}'
                 name='title'
                 placeholder='Título del documento a subir.'>
        </div>
        <div class='#{gz.Css \form-group}'>
          <label for='eife'>Documento</label>
          <input type='file' id='eife' name='file'>
          <p class='#{gz.Css \help-block}'>Arhivo a subir.</p>
        </div>
      "

    __func _body, 1, '0', ~>

      reload-treeview = ~>
        App.ajax._get '/api/document/list', null, do
          _success: (_tree) ~>
              @treeview.render _tree
            ## @_desktop._spinner-stop!
            ## @_desktop._unlock!
          _error: -> alert '558eb4b8-5b26-11e5-be89-001d7d7379f5'


      _modal = new App.widget.message-box.Modal do
        _title: 'Agregar nuevo documento'
        _body: _body
      _modal._footer.html = "
        <button type='button'
                class='#{gz.Css \btn} #{gz.Css \btn-primary}'>
          Aceptar
        </button>
      "
      _modal._footer._first.on-click ->
        _dto =
          'pid': parseInt _body._last.'previousElementSibling'._value
          'title': _file._first._last._value
        ## window.kkk = _file._last._first._next

        uri = '/api/document'
        xhr = new XMLHttpRequest!
        fd = new FormData!

        file = _file._last._first._next.files[0]

        fd.append 'pid', _body._last.'previousElementSibling'._value
        fd.append 'title', _file._first._last._value

        xhr.open 'post', uri, true
        xhr.onreadystatechange = ->
          if xhr.readyState == 4 and xhr.status == 200
            _modal._hide!
            reload-treeview!

        fd.append 'file', file
        xhr.send fd
        ## App.ajax._post '/api/document', _dto, do
        ##   _success: ->
        ##     _modal._hide!
        ##   _error: -> alert 'Loop wr'
      _modal._body._append _file
      _modal._show!

  /** @override */
  render: ->
    @_desktop._lock!
    @_desktop._spinner-start!
    App.ajax._get '/api/document/list', null, do
      _success: (_tree) ~>
        @render-controls!

        # treeview
        @treeview-container = App.dom._new \div
          .._class = gz.Css \col-md-4

          @treeview = new Treeview
            ..on (gz.Css \leaf-click), (hdr-id) ~>
              @_current-node = null
              App.ajax._get "/api/document/#{hdr-id}/getbody", null, do
                _success: (_body) ~>
                  @_viewer.html = _body
                  @_current-node = hdr-id
                _error: -> alert '95c4c788-5b2c-11e5-be89-001d7d7379f5'
          .._append (@treeview.render _tree .el)

          @el._append ..

        # viewer
        @_viewer = App.dom._new \div
          .._class = gz.Css \col-md-8
          ..css = 'background-color:#fffecd'
          @el._append ..


        @_desktop._spinner-stop!
        @_desktop._unlock!
      _error: -> alert '2553a338-575e-11e5-a88b-001d7d7379f5'
    super!


  /** @private */ treeview: null
  /** @private */ treeview-container: null
  /** @private */ _viewer: null
  /** @private */ _current-node: null

  /** @protected */ @@_caption = 'LEGISLACIÓN'
  /** @protected */ @@_icon    = gz.Css \print
  /** @protected */ @@_hash    = 'auth-hash-documents'


/** @export */
module.exports = Documents


/* vim: ts=2 sw=2 sts=2 et: */
