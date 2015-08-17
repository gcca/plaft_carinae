/**
 * @module modules
 * @author Javier Huaman
 */


Module = require '../workspace/module'

class Simulate extends Module

  /** @override */
  _tagName: \div

  simulate: ->
    @_desktop._lock!
    @_desktop._spinner-start!
    App.ajax._get '/api/customs_agency/dispatches_in_operation', true, do
      _success: (dispatches) ~>
        @render-table dispatches
        @_desktop._unlock!
        @_desktop._spinner-stop!
      _error: ->
        alert '25097ebe-4522-11e5-8c7e-904ce5010430'


  render-table: (collection) ->
    _table = App.dom._new \table
      .._class = gz.Css \table

    t-head = App.dom._new \thead
      ..html = '<tr>
                  <th>Razón Social/Nombre</th>
                  <th>Despachos</th>
                </tr>'
    _table._append t-head

    t-body = App.dom._new \tbody

    for dispatches in collection
      _tr = App.dom._new \tr
      _ul = App.dom._new \ul
        ..css = 'padding: 0px'

      for dispatch in dispatches
        _li = App.dom._new \li
          ..html = "#{dispatch.'order'} - #{dispatch.'amount'}"
          _ul._append ..

      App.dom._new \td
        ..html = dispatches.'0'.'customer'.'name'
        _tr._append ..

      App.dom._new \td
        .._append _ul
        _tr._append ..

      t-body._append _tr

    t-body.html = "<tr colspan='2'>
                    <td>No se encontró operaciones múltiples</td>
                   </tr>" if collection._length is 0

    _table._append t-body

    @el._last
      ..html = ''
      .._append _table

  /** @override */
  render: ->
    @clean!
    @el.html = "
      <span>
        &nbsp;&nbsp;&nbsp;&nbsp;
        <i class='#{gz.Css \glyphicon} #{gz.Css \glyphicon-hand-down}'
            style='font-size:20pt'></i>
        \ &nbsp;&nbsp;
        <span style='vertical-align:super'>
          Seleccione el botón para simular las operaciones múltiples</span>
      </span><br>
      <button style='margin:5px'
              class='#{gz.Css \btn} #{gz.Css \btn-primary}'>Simular</button>
      <div class='#{gz.Css \col-md-12}'></div>"

    (@el.query '.btn-primary').on-click ~> @simulate!

    super!


  /** @protected */ @@_caption = 'SIMULACIÓN DE OPERACIONES'
  /** @protected */ @@_icon    = gz.Css \filter
  /** @protected */ @@_hash    = 'auth-hash-simulate'


/** @export */
module.exports = Simulate


/* vim: ts=2 sw=2 sts=2 et: */
