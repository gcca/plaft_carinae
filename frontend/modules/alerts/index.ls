/**
 * @module modules
 */

FieldType = App.builtins.Types.Field
Module = require '../../workspace/module'

panelgroup = App.widget.panelgroup
  PanelGroup = ..PanelGroup
  PanelHeaderClosable = ..PanelHeaderClosable
  PanelBody = ..PanelBody

Modal = require './modal'


class HeadAlert extends PanelHeaderClosable

  _remove-panel: ~>
    _r = super!
    @trigger (gz.Css \removed-title), @el._first._first.html # TODO: Agregar a base.less
    _r

class PendingAlerts extends App.View

  _tagName: \div

  /** @override */
  _className: gz.Css \col-md-12

  _add: (_alert) ->
    @_alerts._push _alert
    @render!

  _open-modal: ~>
    @_boolean = true
    @_modal._open @_load-alerts!

  _filter: ~>
    @_boolean = false
    query = @_input._value.to-upper-case!
    if query is ''
      $ @_pool-alert ._hide!
      return

    for _div in @_divs
      $ _div ._show!

    @_indexes = new Array

    for _alert, i in @_alerts
      _alert = _alert.to-upper-case!
      if (_alert._index query) is -1
        @_indexes._push i

    for i in @_indexes
      $ @_divs[i] ._hide!

    $ @_pool-alert ._show!

  click: (_alert) ->
    @_alerts._remove _alert
    @trigger (gz.Css \change), _alert # TODO: Agregar a base.less
    @_load-alerts!
    $ @_pool-alert ._hide!

  _on-click: ~>
    @click it._target.html
    if @_boolean
      @_modal._close!

  _load-alerts: ->
    @_pool-alert.html = ''
    for _alert in @_alerts
      _div = App.dom._new \div
        .._class = "#{gz.Css \bg-info}"
        ..html = "#{_alert}"
        ..css = "padding:8px;cursor:pointer;margin-bottom:5px"
        ..on-click @_on-click
      @_divs.push  _div
      @_pool-alert._append _div
    @_pool-alert

  /** @override */
  initialize: ({@_alerts=[]}) ->
    @_modal = new Modal
    super!

  /** @override */
  render: ->
    id-view-all = App.utils.uid 'i'
    id-search = App.utils.uid 'i'
    id-pool = App.utils.uid 'i'
    @el.css = "margin-bottom:15px"
    @el.html = "
    <div style='margin-bottom:15px'>
      <div class='#{gz.Css \input-group}'>
        <span class='#{gz.Css \input-group-btn}'>
          <button id='#{id-view-all}' type='button'
            class='#{gz.Css \btn} #{gz.Css \btn-default}'>
            &nbsp;
            <i class='#{gz.Css \glyphicon}
                    \ #{gz.Css \glyphicon-plus}'>
            </i>
            &nbsp;
          </button>
          <button id='#{id-search}' type='button'
                  class='#{gz.Css \btn} #{gz.Css \btn-default}'>
            &nbsp;
            <i class='#{gz.Css \glyphicon}
                    \ #{gz.Css \glyphicon-search}'>
            </i>
            &nbsp;
          </button>
        </span>
        <input type='text'
               class='#{gz.Css \form-control}'
               placeholder='Buscar'>
      </div>
    </div>
    <div id='#{id-pool}'></div>"

    @el._first._append @_modal.render!.el

    @_input = @el.query 'input'
    _search = @el.query "##{id-search}"
    _all = @el.query "##{id-view-all}"

    @_pool-alert = @el.query "##{id-pool}"

    @_divs = new Array

    @_load-alerts!

    $ @_pool-alert ._hide!

    _search.on-click @_filter
    @_input.on-key-up @_filter
    super!

  /** @private */ _alerts: null
  /** @private */ _divs: null
  /** @private */ _all: null
  /** @private */ _input: null
  /** @private */ _pool-alert: null
  /** @private */ _modal: null
  /** @private */ _boolean: false

class CurrentAlerts extends PanelGroup

  /** @override */
  _tagName: \div

  _add: (_alert) ->
    @_alerts._push _alert
    @render!

  /** @override */
  initialize: ({@_alerts=[]}=App._void._Object) ->
    super!

  /** @override */
  render: ->
    @$el.removeAttr('class')
    @$el.removeAttr('id')
    @el.html = ''
    @el.html = "<div class='#{gz.Css \col-md-12}'></div>"
    @root-el = @el._first

    _frm = App.dom._new \form
    App.builder.Form._new _frm, _FIELD_SIGNAL
      ..render!
      .._free!
    if @_alerts
      for _alert in @_alerts
        pnl-head = new HeadAlert _title: _alert
        pnl-body = new PanelBody _element: _frm
        @new-panel do
          _panel-heading: pnl-head
          _panel-body: pnl-body

        pnl-head.on (gz.Css \removed-title), ~>
          @_alerts._remove it
          @trigger (gz.Css \removed), it # TODO: Agregar a base.less

    super!

  /** _FIELDS */
  _FIELD_SIGNAL =
    * _name: 'id_signal'
      _label: 'Código'

    * _name: 'signal'
      _label: 'Descripción de la señal de alerta'
      _type: FieldType.kComboBox
      _options: App.lists.alerts._display

    * _name: 'source'
      _label: 'Fuenta de la señal de la alerta'
      _type: FieldType.kComboBox
      _options:
        'Sistema de Monitoreo'
        'Área Comercial'
        'Análisis del SO'
        'Medio Periodistico'
        'Otras Fuentes'

    * _name: 'description_source'
      _label: 'Descripción de otros.'

  /** @private */ _alerts: null

class Alerts extends Module

  /** @override */
  initialize: ->
    @_dto = ["ADBadb","123123","asd123","bnm890","iopqwe"]
    super!

  /** @override */
  render: ->
    pending-alerts = new PendingAlerts _alerts: @_dto
    current-alerts = new CurrentAlerts # _alerts: []

    pending-alerts.on (gz.Css \change), ~>
      current-alerts._add it

    current-alerts.on (gz.Css \removed), ~>
      pending-alerts._add it

    @el._append pending-alerts.render!.el
    @el._append current-alerts.render!.el

    super!

  /** @protected */ @@_caption = 'ALERTAS'
  /** @protected */ @@_icon    = gz.Css \record
  _dto: null

/** @export */
module.exports = Alerts


/* vim: ts=2 sw=2 sts=2 et: */
