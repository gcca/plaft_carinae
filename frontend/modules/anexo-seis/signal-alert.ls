

Module = require '../../workspace/module'
Utils = require './utils-anexo6'
Alerts = require './alerts'

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
class Alert extends Module

  /** @override */
  _tagName: \form

  /** @override */
  on-save: ~>
    App.ajax._post "/api/dispatch/#{@model._id}/anexo_seis", @_toJSON!, do
      _success: ~>
        @_desktop.notifier.notify do
          _message : 'Se actualizó correctamente los datos'
          _type    : @_desktop.notifier.kSuccess
      _bad-request: ~>
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'


  /** @override */
  render: ->
    _alerts = App.lists.alerts._display
    _dto = [_alerts[i*4] for i from 1 to 7]

    _panel-group = new Alerts
    _panel-group._fromJSON _dto
    @el._append _panel-group.render!.el
    super!



/**
* @Class Operations
* @extends Module
*/
class ListAlerts extends Module

  /** @override */
  render: ->
    (new Utils do
      _desktop: @_desktop
      _parent: @
      _child: Alert)._load-module!

    super!


  /** @protected */ @@_caption = 'SEÑALES DE ALERTA'
  /** @protected */ @@_icon    = gz.Css \flash
  /** @protected */ @@_hash    = 'SAA-HASH'


/** @export */
module.exports = ListAlerts




# vim: ts=2:sw=2:sts=2:et
