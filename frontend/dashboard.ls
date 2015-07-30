/**
 * Dashboard module manage all features allow to officier employee.
 * @module dashboard
 */


App = require './app'


PRE-MODULES =
  Welcome       = require './modules/welcome'
  Income        = require './modules/income'
  Numeration    = require './modules/numeration'
  Operation     = require './modules/operation'
  #OperationList = r equire './modules/operation-list'
  Report  = require './modules/monthy_report'

MODULES = new Array

_allowed-modules = App.permissions.modules
for module in PRE-MODULES
  if module._hash in _allowed-modules # autorización de usuarios
    MODULES._push module

# HARDCODE
BETAS =
  NewUser = require './modules/new-user'
  ModuleTest = require './modules/anexo-seis/module-test'
  Anexo6  = require './modules/anexo-seis'
  ReporteAnexo6 = require './modules/anexo-seis/reporte-anexo6'
  ListAlerts  = require './modules/anexo-seis/signal-alert'
  Alerts  = require './modules/alerts'

username = window.plaft.'user'.'username'

if username in <[cesarvargas@cavasoftsac.com nina@mass.dyn]>
  MODULES ++= BETAS
# END 1 HARDCODE


App.MODULES = MODULES

Workspace = require './workspace'
Settings = require './settings'


/**
 * Dashboard
 * ---------
 * Main workspace to officier and informants.
 * Layout:
 *
 *  - - - - - - - - - - - - - -
 * |          top-bar   search |
 * |_ _ _ _ _ _ _ _ _ _ _ _ _ _|
 * |                           |
 * |                           |
 * |         workspace         |
 * |                           |
 * |                           |
 * |_ _ _ _ _ _ _ _ _ _ _ _ _ _|
 * |_ _ _ bottom (footer) _ _ _|
 *
 * @class Dashboard
 * @extends View
 */
class Dashboard extends App.View

  /** @override */
  el: $ \body

  /**
   * (Event) Toggle admin users view: dashboard - settings.
   * @param {Event} evt
   * @private
   */
  toggle-settings: (evt) ~>
    @_content._first._class._toggle gz.Css \hidden

    if @_settings
      evt._target._first.html = 'Usuarios'
      @_settings._free!
      @_settings = null
    else
      evt._target._first.html = 'Principal'
      @_settings = Settings._new!
      @_content._append @_settings.render!.el

  /** @override */
  render: ->
    @el.html = @template
    @_content = @el._first._next
    x-search = @el.query "##{gz.Css \search}"
    x-save = @el.query "##{gz.Css \save}"

    workspace = new Workspace do
      search-place: x-search
      save-place: x-save

    @_content._append workspace.render!.el

    x-search._first._class._add gz.Css \navbar-form

    @el.query "##{gz.Css \id-settings-users}" .on-click @toggle-settings

    workspace.load-module Welcome

    # HARDCODE
    _m-ref = BETAS.0
    _el = workspace.el.query ".#{gz.Css \glyphicon}-#{_m-ref._icon}"
    if _el?
      _el = _el._parent._parent
      _el.css = 'border-top:2px solid #bbb'
    # END 2 HARDCODE

    super!


  /** @private */ _content: null
  /** @private */ _settings: null

  /** @override */
  template: "
    <header class='#{gz.Css \navbar}
                 \ #{gz.Css \navbar-inverse}
                 \ #{gz.Css \navbar-fixed-top}'
          role='banner'>
      <div class='#{gz.Css \container}'>
        <div class='#{gz.Css \navbar-header}'>
          <button class='#{gz.Css \navbar-toggle}' type='button'
              data-toggle='collapse'
              data-target='##{gz.Css \id-navbar-collapse}'>
            <span class='#{gz.Css \sr-only}'>Toggle navigation</span>
            <span class='#{gz.Css \icon-bar}'></span>
            <span class='#{gz.Css \icon-bar}'></span>
            <span class='#{gz.Css \icon-bar}'></span>
          </button>

          <a href='#' class='#{gz.Css \navbar-brand}'>
            #{window.'plaft'.'user'.'customs_agency'.'name'}
          </a>
        </div>
        <nav class='#{gz.Css \collapse}
                  \ #{gz.Css \navbar-collapse}'
            id='#{gz.Css \id-navbar-collapse}'
            role='navigation'>
          <ul class='#{gz.Css \nav} #{gz.Css \navbar-nav}'>
            <li class='#{gz.Css \dropdown}'>
              <a href='#' class='#{gz.Css \dropdown-toggle}'
                  data-toggle='dropdown'>
                Opciones <span class='#{gz.Css \caret}'></span>
              </a>
              <ul class='#{gz.Css \dropdown-menu}' role='menu'>
                <li id='#{gz.Css \id-settings-users}'><a>Usuarios</a></li>
                <li class='#{gz.Css \divider}'></li>
                <li><a href='/signout'>Salir</a></li>
              </ul>
            </li>
          </ul>
          <div id='#{gz.Css \save}'
              class='#{gz.Css \navbar-right} #{gz.Css \navbar-form}'
              role='save'>
          </div>
          <div id='#{gz.Css \search}' class='#{gz.Css \navbar-right}'
              role='search'>
          </div>
        </nav>
      </div>
    </header>

    <div class='#{gz.Css \container} #{gz.Css \app-container}'></div>

    <footer style='padding-top:40px;
                   padding-bottom:30px;
                   margin-top:100px'></footer>"


(new Dashboard).render!


# Developer shortcuts and options
# Remove in production release

# Switch user

user = window.'plaft'.'user'
employees = user.'customs_agency'.'employees'
officer = user.'customs_agency'.'officer'
if officer._constructor is Number
  officer = user

employee_items = ["<li> \
                     <a href='/switch/#{..'id'}'>#{..'username'}</a> \
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
        <li><a href='/switch/#{officer.'id'}'>#{officer.'username'}</a></li>
        <li class='#{gz.Css \divider}'></li>
        #{employee_items.join ''}
      </ul>
    </li>"

if window.'plaft'.'ig'
  App.dom.query '#id-navbar-collapse' ._append _swbar


# vim: ts=2:sw=2:sts=2:et
