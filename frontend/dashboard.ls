/**
 * Dashboard module manage all features allow to officier employee.
 * @module dashboard
 */


App = require './app'

App.MODULES =
  Welcome       = require './modules/welcome'
  Income        = require './modules/income'
  Numeration    = require './modules/numeration'
  Operation     = require './modules/operation'
  OperationList = require './modules/operation-list'
#  Anexo6        = r equire './modules/anexo-seis'
  Alerts        = require './modules/alerts'

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
            PLAFTsw
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

# document.query('.glyphicon-cloud').click()
# document.query('input').value = '12345678989'
# document.query('select').value = 'order'
# document.query('.glyphicon-search').parentNode.click()

# 2 income
#$ ".#{gz.Css \glyphicon-file}" .parent!.parent!.0.dispatchEvent(
#  new MouseEvent(\click))
#$ "##{gz.Css \search}"
#  #..find 'input' .val 'mlml'
#  ..find 'input' .val '2014-601'
#  #..find 'input' .val '12345678989'
#  ..find 'button' .click!


# 3 settings
#$ "##{gz.Css \id-settings-users}" .0.dispatchEvent (new MouseEvent \click)


# vim: ts=2:sw=2:sts=2:et
