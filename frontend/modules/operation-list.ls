/**
 * @module modules
 */

Module = require '../workspace/module'
Table = App.widget.table.Table

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
  urlRoot: 'operation/list'
  model: Operation


class ControlHeadTable extends panelgroup.ControlTitle

  _tagName: \table

  _className: gz.Css \table

  load-head: (_dto) ->
    @el.css\width = \1000
    @el.html = "<tbody>
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
                </tbody>"

class PanelHeadingTable extends panelgroup.PanelHeading

  _controls : [ControlHeadTable]

class PanelBodyTable extends panelgroup.PanelBody

  load-table: (_dispatches) ->
    @el.css\padding = \0
    _labels =
      '**'
      'N Orden'
      'N DAM'

    _attributes =
      '**'  # TODO:buscar una manera para darle un espacio en blanco.
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

    @el._append _tabla.render!.el

/**
 * @Class OperationList
 * @extends Module
 */
class OperationList extends Module

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
    pnl-group = new panelgroup.PanelGroup
    op._fetch do
      _success: (dispatches) ~>
        for _model in dispatches._models
          @render-panel _model._attributes, pnl-group
          @_desktop._spinner-stop!

      _error: ->
        alert 'Error!!! Numeration list'

    @el._append pnl-group.render!el
#    @$el._append "<a class='#{gz.Css \btn} #{gz.Css \btn-success}'
#                     href='api/reporte_operaciones'>
#                    Generar reporte
#                  </a>

#                  <select class='#{gz.Css \form-control}
#                               \ #{gz.Css \pull-right}'
#                          style='width:125px;margin-left:8px'>
#                    <option>Enero</option>
#                    <option>Febrero</option>
#                    <option>Marzo</option>
#                    <option>Abril</option>
#                    <option>Mayo</option>
#                    <option>Junio</option>
#                    <option>Agosto</option>
#                    <option>Setiembre</option>
#                    <option>Octubre</option>
#                    <option>Noviembre</option>
#                    <option>Diciembre</option>
#                  </select>

#                  <a class='#{gz.Css \btn}
#                          \ #{gz.Css \btn-default}
#                          \ #{gz.Css \pull-right}'
#                     href='#'>
#                    Procesar operaciones múltiples de
#                  </a>"

    super!

  /** @protected */ @@_caption = 'LISTA OPERACION'
  /** @protected */ @@_icon    = gz.Css \th-list
  /** @protected */ @@_hash    = 'OPLIST-HASH'

/** @export */
module.exports = OperationList


/* vim: ts=2 sw=2 sts=2 et: */
