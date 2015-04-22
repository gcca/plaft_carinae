/**
 * @module modules
 */

Module = require '../workspace/module'
table = require '../app/widgets/table'
  Table = ..Table

panelgroup = require '../app/widgets/panelgroup'
  PanelGroup = ..PanelGroup
  PanelHeading = ..PanelHeading
  PanelBody = ..PanelBody

/**
 * @class DispatchModel
 * @extends Model
 */
class DispatchModel extends App.Model
  defaults:
    'declaration': []
    'linked': []
    'declarant': []

/**
 * @class Operation
 * @extends Model
 */
class Operation extends App.Model
  urlRoot: 'operation'


/**
 * @Class Operations
 * @extends Collection
 */
class Operations extends App.Collection
  urlRoot: \operation
  model: Operation


/**
 * @Class OperationList
 * @extends Module
 */
class OperationList extends Module

  /**
   * Carga el heading de acuerdo al dto de la operacion.
   * @param {Object} _dto
   * @return {PanelHeading} _head
   */
  render-head: (_dto) ->
    _title = "<table class='#{gz.Css \table}' style='margin:0'>
                <tbody>
                  <tr>
                    <td style='border-top-style:none;
                               margin:auto;
                               width:162px'>
                    #{_dto.id}
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
                </tbody>
              </table>"

    _head = new PanelHeading _title: _title

  /**
   * Carga la tabla de despachos de una operacion.
   * @param {Object} _dispatches
   * @return {PanelBody} _body
   */
  render-body: (_dispatches) ->
    _labels =
      '**'
      'N Orden'
      'N DAM'

    _attributes =
      '**' # TODO:buscar una manera para darle un espacio en blanco.
      'order'
      'dam'

    _templates =
      '**': ->
        " "

    _tabla = new Table do
                  _attributes: _attributes
                  _labels: _labels
                  _templates: _templates

    for _dispatch in _dispatches
      _model-dispatch = new DispatchModel _dispatch
      _tabla.add-row _model-dispatch

    _tabla.el.css.\margin = \0

    _body = new PanelBody _element: _tabla.render!.el

  /**
   * Carga el panel de acuerdo a las operaciones.
   * @param {Object} _dto
   * @param {PanelGroup} pnl-group
   */
  render-panel: (_dto, pnl-group) ->
    _panel = pnl-group.new-panel do
      _panel-heading: @render-head _dto
      _panel-body: @render-body _dto.dispatches

    _panel.el.css.\border = \none

    _panel._body.el._first.css = "padding:0"

    # Se cambia el header para se paresca a una tabla.
    _panel._header.el.css.\background = \white
    _panel._header.el.css.\padding = \0

    # Se modifica el titulo para que pueda entrar la cabecera.
    _panel._header.el._first._first.css.\width = \1000

    pnl-group.close-all!

  /** @override */
  render: ->
    @clean!
    @el.html = "<table class='#{gz.Css \table}' style='margin:0'>
                  <thead>
                    <tr>
                      <th style='border-top-style:none;margin:auto;'>
                      ORDER
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
    pnl-group = new PanelGroup
    op._fetch do
      _success: (dispatches) ~>
        for _model in dispatches._models
          @render-panel _model._attributes, pnl-group

      _error: ->
        alert 'Error!!! Numeration list'

    @el._append pnl-group.render!el
    @$el._append "<a class='#{gz.Css \btn} #{gz.Css \btn-success}'
                     href='api/reporte_operaciones'>
                    Generar reporte
                  </a>"

    super!

  /** @protected */ @@_caption = 'LISTA OPERACION'
  /** @protected */ @@_icon    = gz.Css \th-list

/** @export */
module.exports = OperationList


/* vim: ts=2 sw=2 sts=2 et: */
