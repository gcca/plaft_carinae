App = require './app'


MODULES =
  Profile  = require './admin/modules/profile'
  User     = require './admin/modules/new-user'
  Billing  = require './admin/modules/billing'

App.MODULES = MODULES
Workspace = require './admin/workspace'

/**
 * Admin
 * -----
 * @class Admin
 * @extends View
 */
class Admin extends App.View

  /** @override */
  el: $ \body

  /** @override */
  render: ->
    @el.html = @template
    @_content = @el._first._next
    x-save = @el.query "##{gz.Css \save}"

    workspace = new Workspace do
      save-place: x-save

    @_content._append workspace.render!.el

    workspace.load-module Profile
    super!

  template: "
    <header class='#{gz.Css \navbar}
                 \ #{gz.Css \navbar-inverse}
                 \ #{gz.Css \navbar-fixed-top}'
          role='banner'>
      <div class='#{gz.Css \container-fluid}'>
        <div class='#{gz.Css \navbar-header}'>
          <a href='#' class='#{gz.Css \navbar-brand}'>
            CavaSoft SAC
          </a>
        </div>
        <nav class='#{gz.Css \collapse}
                  \ #{gz.Css \navbar-collapse}'
             id='#{gz.Css \id-navbar-collapse}'
             role='navigation'>
          <div id='#{gz.Css \save}'
              class='#{gz.Css \navbar-right} #{gz.Css \navbar-form}'
              role='save'>
          </div>
        </nav>
      </div>
    </header>

    <div class='#{gz.Css \container} #{gz.Css \app-container}'></div>

    <footer style='padding-top:40px;
                   padding-bottom:30px;
                   margin-top:100px'></footer>"

  /** @private */ _content: null

(new Admin).render!
