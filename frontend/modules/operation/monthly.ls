/** @module modules */

Module = require '../../workspace/module'
ReportEdit = require './summary'
table = App.widget.table
  Table = ..Table

/**
 * @class Dispatch
 * @extends Model
 */
class Dispatch extends App.Model
  urlRoot: 'dispatch'

/**
 * @class Dispatch
 * @extends Model
 */
class CollectionDispatch extends App.Collection
  model: Dispatch


/**
 * MonthlyReport
 * -------
 *
 * @class MonthlyReport
 * @extends Module
 */
class MonthlyReport extends Module

  /** @override */
  render: ->
    @clean!
    @_desktop._lock!
    @_desktop._spinner-start!

    _labels =
      'N&ordm; Orden'
      'Rég.'
      'N&ordm; Fila'
      'N&ordm; Registro'
      'DAM'
      'Md. Op.'
      'N&ordm; Md.'
      'FOB US$'
      'Fecha Num.'

    _attributes =
      'order'
      'regime.code'
      'row-number'
      'register-number'
      'dam'
      'modality'
      'counter'
      'amount'
      'numeration_date'

    _templates =
      'amount': ->
        if it >10000
          "<span style='color:red'>
            #{(new String(it)).replace /(\d)(?=(\d{3})+\.)/g, "$1, "}
          </span>"
        else
          (new String(it)).replace /(\d)(?=(\d{3})+\.)/g, "$1, "


    @$el._append "<a class='#{gz.Css \btn}
                              \ #{gz.Css \btn-primary}
                              \ #{gz.Css \pull-right}'
                    href='/api/operation/monthly_report'>
                 Generar Reporte
                 </a>"
    App.ajax._get '/api/operation/operations', true, do
      _success: (operations) ~>
        dispatches = new Array
        for o in operations
          for [dispatch, counter] in _.zip o.'dispatches', o.'num_modalidad'
            dispatch.'row-number' = o.'row_number'
            dispatch.'register-number' = o.'register_number'
            dispatch.'modality' = o.'modalidad'
            dispatch.'counter' = counter
            dispatches._push dispatch

        c-dispatches = new CollectionDispatch dispatches

        table-operation = new Table do
                      _attributes: _attributes
                      _labels: _labels
                      _templates: _templates
                      on-dblclick-row: (evt) ~>
                        _model = evt._target._model
                        @_desktop.load-next-page ReportEdit, do
                            model: _model

        table-operation.set-rows c-dispatches
        @el._append table-operation.render!.el
        @_desktop._unlock!
        @_desktop._spinner-stop!
    super!

  /** @protected */ @@_caption = 'RO - PROCESO MENSUAL'
  /** @protected */ @@_icon    = gz.Css \certificate
  /** @protected */ @@_hash    = 'auth-hash-monthly_report'


/** @export */
module.exports = MonthlyReport


# vim: ts=2:sw=2:sts=2:et
