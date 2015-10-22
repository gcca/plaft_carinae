/**
 * Dashboard module manage all features allow to officier employee.
 * @module dashboard
 */


App = require './app'

## Modulos
PRE-MODULES =
  Welcome         = require './modules/welcome'
  Documents       = require './modules/documents'
  Income          = require './modules/income'
  Numeration      = require './modules/numeration'
  [
    'REGISTRO OPERACIONES'
    Operation       = require './modules/operation/daily'
    Report          = require './modules/operation/monthly'
  ]
  [
    'SEÑALES DE ALERTA - OI'
    UnusalAlerts    = require './modules/unusual/alerts'
    UnusualRegister = require './modules/unusual/register'
    UnusualReport   = require './modules/unusual/report'
  ]
  PreviewMulti    = require './modules/preview_multi'

MODULES = new Array

## Permisos
_allowed-modules = App.permissions.modules
__read-permissions = (modules, array) ->
  for module in modules
    if module._constructor is Array
      new-array = new Array
        .._push module[0]
      module = module._slice 1, module._length
      __read-permissions module, new-array
      array._push new-array
    else
      if module._mod-hash in _allowed-modules # autorización de usuarios
        array._push module

## Leer permisos
__read-permissions PRE-MODULES, MODULES


# HARDCODE
BETAS =
  WorkerAlerts  = require './modules/worker-alerts'
  OperationList = require './modules/operation-list'
  Profile       = require './modules/profile'
  Simulate      = require './modules/simulate'
  Debug         = require './modules/debug'

## FIRST MODULE
App.FIRST-MODULE = Welcome

## Nombre en title
App.DISPLAY-NAME = window.'plaft'.'user'.'customs_agency'.'name'

## Menu
Menu = require './workspace-new/menu'

## Lista de menus
MENUS-RENDER = new Array

for modules in [MODULES]
  MENUS-RENDER._push new Menu MODULES: modules

# Usuarios - HARDCODE [ONLY BETAS]
username = window.plaft.'user'.'username'

if username in <[cesarvargas@cavasoftsac.com nina@mass.dyn]>
  MENUS-RENDER._push new Menu MODULES: BETAS
# END 1 HARDCODE

## Workspace
Workspace = require './workspace-new'


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
    @el._append (new Workspace MENUS: MENUS-RENDER ).render!.el
    super!


(new Dashboard).render!


# Switch user

user = window.'plaft'.'user'
employees = user.'customs_agency'.'employees'
officer = user.'customs_agency'.'officer'
if officer._constructor is Number
  officer = user

employee_items = ["<li> \
                     <a href='/switch/#{..'id'}'> \
                       <label style='width:18ex;font-weight:normal'> \
                         #{..'username'} \
                       </label> \
                       <em style='font-size:9pt'>(#{..'role'})</em> \
                     </a> \
                   </li>" \
                  for employees]

_swbar = App.dom._new \div
  .._class = "#{gz.Css \nav} #{gz.Css \navbar-nav}"
  ..html = "
    <li class='#{gz.Css \dropdown}'>
      <a href='#' class='#{gz.Css \dropdown-toggle}' data-toggle='dropdown'>
        Usuario: #{user.'username'} <span class='#{gz.Css \caret}'></span>
      </a>
      <ul class='#{gz.Css \dropdown-menu}' role='menu'>
        <li>
          <a href='/switch/#{officer.'id'}'>
            #{officer.'username'}
            &nbsp;&nbsp;&nbsp;&nbsp;
            <em style='font-size:9pt'>(Oficial de cumplimiento)</em>
          </a>
        </li>
        <li class='#{gz.Css \divider}'></li>
        #{employee_items.join ''}
      </ul>
    </li>"

if username in <[cesarvargas@cavasoftsac.com nina@mass.dyn]>
  ## if window.'plaft'.'ig'
  App.dom.query "##{gz.Css \id-navbar-collapse}" ._append _swbar

# vim: ts=2:sw=2:sts=2:et
