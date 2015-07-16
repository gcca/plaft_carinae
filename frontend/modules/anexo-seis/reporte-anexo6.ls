/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../../workspace/module'
SignalAlerts = require './alerts'
Utils = require './utils-anexo6'

FieldType = App.builtins.Types.Field


/**
* @class Dispatch
* @extends Model
*/
class Dispatch extends App.Model
  urlRoot: 'dispatch'


/**
* @Class Dispatches
* @extends Collection
*/
class Dispatches extends App.Collection
  urlRoot: 'customs_agency/pending'
#  urlRoot: 'dispatch'
  model: Dispatch


/**
* @Class OperationEdit
* @extends Module
*/
class Reporte extends Module

  /** @override */
  _tagName: \form

  empty-field: (value) ->
    _span = App.dom._new \span
      ..css = 'color:red;font-size:22px'
      ..title = 'TITLE'
      ..html = '*'
      $ .. ._tooltip do
        'template': "<div class='#{gz.Css \tooltip}' role='tooltip'
                          style='min-width:175px'>
                       <div class='#{gz.Css \tooltip-arrow}'></div>
                       <div class='#{gz.Css \tooltip-inner}'></div>
                     </div>"
    if value?
      if value is ""
        return _span
      else
        return value
    else
      return _span

  add-table: (list, _dto) ->
    _table = App.dom._new \table
      .._class = "#{gz.Css \table}
                \ #{gz.Css \table-bordered}"
    _tbody = App.dom._new \tbody
    for r in list
      _tr = App.dom._new \tr

      App.dom._new \td
        ..css = 'width: 0.5%'
        ..html = r[0]
        _tr._append ..

      App.dom._new \td
        .._class = gz.Css \col-md-7
        $ .. ._append r[1]
        _tr._append ..

      App.dom._new \td
        .._class = gz.Css \col-md-5
        $ .. ._append @empty-field r[2] _dto
        _tr._append ..

      _tbody._append _tr

    _table._append _tbody
    _table

  /** @override */
  render: ->
    dispatch = @model._attributes
    operation = App.lists.anexo6.operation._display
    alerts = App.lists.anexo6.alerts._display
    person = App.lists.anexo6.person._display

    # PERSON
    @$el._append "<h4>#{person[0]}</h4>"
    @el._append @add-table person[1], dispatch.'declaration'.'customer'

    # STAKEHOLDER
    for stk in dispatch.'stakeholders'
      @el._append @add-table person[1], stk

    # OPERATION
    @$el._append "<h4>#{operation[0]}</h4>"
    @el._append @add-table operation[1], dispatch

    # ALERTS
    @$el._append "<h4>#{alerts[0]}</h4>"
    @el._append @add-table alerts[1], dispatch.'alerts'

    super!


/**
* @Class Operations
* @extends Module
*/
class ReporteAnexo6 extends Module

  /** @override */
  render: ->
    (new Utils do
      _desktop: @_desktop
      _parent: @
      _child: Reporte)._load-module!

    super!


  /** @protected */ @@_caption = 'OPERACIONES INUSUALES-ANEXO 6'
  /** @protected */ @@_icon    = gz.Css \flash
  /** @protected */ @@_hash    = 'ANX6-HASH'


/** @export */
module.exports = ReporteAnexo6


/* vim: ts=2 sw=2 sts=2 et: */
