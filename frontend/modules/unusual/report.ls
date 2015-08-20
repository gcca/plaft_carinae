/**
 * @module modules
 * @author Javier Huaman
 */

Module = require '../../workspace/module'
Utils = require './table'

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
  model: Dispatch


/**
 * Report
 * --------
 *
 * @Class Report
 * @extends Module
 */
class Report extends Module

  /** @override */
  _tagName: \div

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

    pdf-report = App.dom._new \a
      .._class = "#{gz.Css \btn} #{gz.Css \btn-primary} #{gz.Css \pull-right}"
      ..css = 'margin: 20px'
      ..href = "api/dispatch/#{dispatch.id}/unusual_report"
      ..target = '_blank'
      ..html = 'Exportar a PDF'
      @el._append ..

    # PERSON
    @$el._append "<h4>#{person[0]}</h4>"
    @el._append @add-table person[1], dispatch.'declaration'.'customer'

    # STAKEHOLDER
    for stk in dispatch.'stakeholders'
      @el._append @add-table person[1], stk

    # OPERATION
    @$el._append "<h4>#{operation[0]}</h4>"
    @el._append @add-table operation[1], dispatch

    for alert in dispatch.'alerts'
      # ALERTS
      @$el._append "<h4>#{alerts[0]}</h4>"
      @el._append @add-table alerts[1], alert

    super!


/**
 * ListReport
 * --------
 *
 * @Class ListReport
 * @extends Module
 */
class ListReport extends Module

  /** @override */
  render: ->
    (new Utils do
      _desktop: @_desktop
      _parent: @
      _child: Report)._load-module!

    super!


  /** @protected */ @@_caption = 'OPERACIONES INUSUALES-ANEXO 6'
  /** @protected */ @@_icon    = gz.Css \flash
  /** @protected */ @@_hash    = 'auth-hash-report'


/** @export */
module.exports = ListReport


/* vim: ts=2 sw=2 sts=2 et: */
