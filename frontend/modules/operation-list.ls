/**
 * @module modules
 */

Module = require '../workspace/module'
Table = App.widget.table.Table
modal = App.widget.message-box

panelgroup = App.widget.panelgroup

/**
 * @class DispatchModel
 * @extends Model
 */
class DispatchModel extends App.Model
  defaults:
    'declaration': []
    'stakeholders': []
    'declarants': []

/**
 * @class Operation
 * @extends Model
 */
class Operation extends App.Model


/**
 * @Class Operations
 * @extends Collection
 */
class Operations extends App.Collection
  urlRoot: 'operation/operations'
  model: Operation

/**
 * ControlHeadTable
 * --------
 *
 * @class ControlHeadTable
 * @extends ControlTitle
 */
class ControlHeadTable extends panelgroup.ControlTitle

  /** @override */
  _tagName: \table

  /** @override */
  _className: gz.Css \table

  load-head: (_dto) ->
    @el.css\width = \1000
    @el.html = "<tbody>
                  <tr>
                    <td style='border-top-style:none;
                               margin:auto;
                               width:162px'>
                    N&ordm; #{_dto.row_number}
                    </td>
                    <td style='border-top-style:none;
                               margin:auto;
                               width:400px'>
                    #{_dto.customer.name}
                    </td>
                    <td style='border-top-style:none;
                               margin:auto;
                               width:413px'>
                    #{_dto.dispatches.length}
                    </td>
                  </tr>
                </tbody>"

/**
 * PanelHeadingTable
 * --------
 *
 * @class PanelHeadingTable
 * @extends PanelHeading
 */
class PanelHeadingTable extends panelgroup.PanelHeading

  _controls : [ControlHeadTable]

/**
 * PanelBodyTable
 * --------
 *
 * @class PanelBodyTable
 * @extends PanelBody
 */
class PanelBodyTable extends panelgroup.PanelBody

  load-table: (_dispatches) ->
    @el.css\padding = \0
    _labels =
      '**'
      'N&ordm; Orden'
      'N&ordm; DAM'
      'Fec. Numeración'

    _attributes =
      '**'  # TODO:buscar una manera para darle un espacio en blanco.
      'order'
      'dam'
      'numeration_date'

    _templates =
      '**': -> ''

    _tabla = new Table do
                  _attributes: _attributes
                  _labels: _labels
                  _templates: _templates

    for _dispatch in _dispatches
      _model-dispatch = new DispatchModel _dispatch
      _tabla.add-row _model-dispatch

    _tabla.el.css.\margin = \0

    @el._append _tabla.render!.el

/**
 * OperationList
 * --------
 *
 * @Class OperationList
 * @extends Module
 */
class OperationList extends Module


  on-monthly-closure: ->
    _callback = (_value) ~>
      if _value
        App.ajax._post '/api/customs_agency/close_month', null, do
          _success: (response) ~>
            if response
              @_desktop.notifier.notify do
                _message: 'Se cerró el mes.'
                _type: @_desktop.notifier.kSuccess

              @_desktop._reload!
            else
              @_desktop.notifier.notify do
                _message: 'Todavia no puede cerrar el mes'
                _type: @_desktop.notifier.kDanger

          _bad-request: ~>
            alert '6e427fc2-450e-11e5-92b1-904ce5010430'

    message = modal.MessageBox._new do
      _title: 'Cerrando el mes.'
      _body: '<h5>¿Desea cerrar el mes?</h5>'
      _callback: _callback
    message._show!

  /**
   * Carga el panel de acuerdo a las operaciones.
   * @param {Object} _dto
   * @param {PanelGroup} pnl-group
   */
  render-panel: (_dto, pnl-group) ->
    _panel = pnl-group.new-panel do
          _panel-heading: PanelHeadingTable
          _panel-body: PanelBodyTable
    _panel._header._get ControlHeadTable .load-head _dto
    _panel._body.load-table _dto.dispatches

    # styles
    _panel._header.el.css
      ..\margin = \0
      ..\background = \white
      ..\padding = \0

    _panel.el.css.\border = \none


    pnl-group.close-all!

  /** @override */
  render: ->
    @_desktop._spinner-start!

    @clean!
    @el.html = "<table class='#{gz.Css \table}' style='margin:0'>
                  <thead>
                    <tr>
                      <th style='border-top-style:none;margin:auto;'>
                      ORDEN
                      </th>
                      <th style='border-top-style:none;margin:auto;'>
                      Nombre/Razon Social
                      </th>
                      <th style='border-top-style:none;margin:auto;'>
                      Cantidad de Despacho
                      </th>
                    </tr>
                  </thead>
                </table>"

    op = new Operations
    pnl-group = new panelgroup.PanelGroup
    op._fetch do
      _success: (dispatches) ~>
        for _model in dispatches._models
          @render-panel _model._attributes, pnl-group
      _error: ->
        alert 'Error!!! Numeration list'
    @el._append pnl-group.render!el

    App.dom._new \button
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}
                \ #{gz.Css \pull-right}"
      ..html = 'Cierre mensual e identificación de operaciones'
      ..on-click ~> @on-monthly-closure!
      @el._append ..

    @_desktop._spinner-stop!
    super!

  /** @protected */ @@_caption = 'REGISTRO OPERACION'
  /** @protected */ @@_icon    = gz.Css \th-list
  /** @protected */ @@_hash    = 'auth-hash-operation-list'

/** @export */
module.exports = OperationList


/* vim: ts=2 sw=2 sts=2 et: */
