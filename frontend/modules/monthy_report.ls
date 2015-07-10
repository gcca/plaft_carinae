/** @module modules */

Module = require '../workspace/module'


/**
 * Welcome
 * -------
 * Welcome page for dashboard.
 * @class Welcome
 * @extends Module
 */
class MonthyReport extends Module


  add-head: ->
    _tr = App.dom._new \tr
    for k in &
      _td = App.dom._new \td
        ..css = 'text-align: center;width:50px;padding-left:0;padding-right:0'
        ..html = k
      _tr._append _td
    _thead = App.dom._new \thead
    _thead._append _tr
    @_table._append _thead

  add-row: ->
    _tr = App.dom._new \tr
    for k in &
      _td = App.dom._new \td
        ..css = 'text-align: center;width:50px;padding-left:0;padding-right:0'
        ..html = k
      _tr._append _td
    @_tbody._append _tr

  add-table: (operations) ->
      @_table = App.dom._new \table
        .._class = "#{gz.Css \table} #{gz.Css \table-hover}"
      @_tbody = App.dom._new \tbody

      @add-head 'No Orden', 'Regimen', 'No Fila' ,'No Registro',
                'Modalidad O.', 'No Modalidad', 'FOB', 'Monto S/.'
      for operation in operations
        for [dispatch, i] in _.zip operation.'dispatches', operation.'num_modalidad'
          amount = parseFloat dispatch.'amount'
          change = parseFloat dispatch.'exchange_rate'
          @add-row dispatch.'order',
                   dispatch.'regime'.'code',
                   operation.'row_number',
                   operation.'register_number',
                   operation.'modalidad',
                   i,
                   "#{if amount >10000 then "<span style='color:red'>#{amount}</span>" else amount }",
                   (amount*change).to-fixed 2

      @_table._append @_tbody
      @el._append @_table

  /** @override */
  render: ->
    @clean!
    @_desktop._lock!
    @_desktop._spinner-start!
    App.ajax._get '/api/operation/operations', true, do
      _success: (_dto) ~>
        @add-table _dto
        @_desktop._unlock!
        @_desktop._spinner-stop!
    super!

  _table: null
  _tbody: null
  /** @protected */ @@_caption = 'REPORTE MENSUAL'
  /** @protected */ @@_icon    = gz.Css \certificate
  /** @protected */ @@_hash  = 'REPORTE-M-HASH'


/** @export */
module.exports = MonthyReport


# vim: ts=2:sw=2:sts=2:et
