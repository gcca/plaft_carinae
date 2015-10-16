/**
 * Dashboard module manage all features allow to officier employee.
 * @module dashboard
 */


App = require './app'


MODULES =
  Welcome         = require './modules/welcome'
  Documents       = require './modules/documents'
  Income          = require './modules/income'
  Numeration      = require './modules/numeration'
  Operation       = require './modules/operation/daily'
  Report          = require './modules/operation/monthly'
  UnusalAlerts    = require './modules/unusual/alerts'
  UnusualRegister = require './modules/unusual/register'
  UnusualReport   = require './modules/unusual/report'
  PreviewMulti    = require './modules/preview_multi'

App.MODULES = MODULES

BETAS =
  TestIII    = require './test/test-moduleIII'
  [
    'Agrupamiento'
    TestIV    = require './test/test-moduleIV'
  ]

SETTINGS =
  TestI    = require './test/test-module'
  TestVI    = require './test/test-moduleVI'

Menu = require './workspace-new/menu'

MENUS-RENDER =
  new Menu MODULES: MODULES
  new Menu MODULES: BETAS

WorkspaceNew = require './workspace-new'


# DTO to Dispatch model
__counter =
  _current: window.'plaft'.'counter'
  _ids: null

__counter-update = (dispatches_pa) ->
  dispatches = new Array
  Dispatch = App.model.Dispatch
  Dispatches = App.model.Dispatches
  for k of dispatches_pa
    collection-k = new Array
    for dto, i in dispatches_pa[k]
      dispatch = new Dispatch dto
      collection-k._push dispatch
      dispatches._push dispatch
    dispatches_pa[k] = new Dispatches collection-k
  window.'plaft'.'dispatches' = new Dispatches dispatches
  __counter._ids = [.._id for dispatches]
__counter-update window.'plaft'.'dispatches_pa'

__method-counter = (_callback, ..._collections) ->
  App.ajax._get '/api/iocounter', on, do
    _success: (_io) ->
      new-counter = _io.'counter'
      if new-counter != __counter._current
        # TODO: improve fetching only modified dispatches from datastore.
        #       Maybe using cache to store the modified keys by counter
        #       and eval the last version to fetch.
        App.ajax._get '/api/customs_agency/list_dispatches', true, do
          _success: (dispatches_pa) ~>
            __counter-update dispatches_pa
            window.'plaft'.'dispatches_pa' = dispatches_pa
            _callback.apply @, _collections
          _error: ->
            alert 'ERROR: 8250d1be-4de0-11e5-8eed-001d7d7379f5'
      else
        _callback.apply @, _collections
    _error: ->
      alert 'ERROR: counter'  # TODO: message


App.model.Dispatches <<<
  _all: (_callback) ->
    __method-counter _callback, window.'plaft'.'dispatches'

  _pending: (_callback) ->
    __method-counter _callback, window.'plaft'.'dispatches_pa'.'pending'

  _accepting: (_callback) ->
    __method-counter _callback, window.'plaft'.'dispatches_pa'.'accepting'

  _both: (_callback) ->
    __method-counter(_callback,
                     window.'plaft'.'dispatches_pa'.'pending',
                     window.'plaft'.'dispatches_pa'.'accepting')

  add-new: (dispatch) ->
    if dispatch._id not in __counter._ids
      window.'plaft'.'dispatches'.'unshift' dispatch
      window.'plaft'.'dispatches_pa'.'pending'.'unshift' dispatch
      __counter._ids._push dispatch._id


class Dashboard extends App.View

  el: $ \body

  render: ->
    @el._append (new WorkspaceNew MENUS: MENUS-RENDER ).render!.el
    super!


(new Dashboard).render!


# vim: ts=2:sw=2:sts=2:et
