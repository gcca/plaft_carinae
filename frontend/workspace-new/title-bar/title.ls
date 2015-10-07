/** @module workspace.titlebar */

MODULES = App.MODULES


class Title extends App.View

  /** @override*/
  _tagName: \div

  /** @override*/
  _className: gz.Css \navbar-header

  /** Evento : carga el primer modulo */
  load-first-module: ~>
    @trigger (gz.Css \title), MODULES[0]

  /** @override*/
  initialized: ({@title}) -> super!

  /** @override*/
  render: ->
    @el.html = "<button class='#{gz.Css \navbar-toggle}' type='button'
                         data-toggle='collapse'
                         data-target='##{gz.Css \id-navbar-collapse}'>
                   <span class='#{gz.Css \sr-only}'>Toggle navigation</span>
                   <span class='#{gz.Css \icon-bar}'></span>
                   <span class='#{gz.Css \icon-bar}'></span>
                   <span class='#{gz.Css \icon-bar}'></span>
                 </button>"
    a-title = App.dom._new \a
      .._class = gz.Css \navbar-brand
      ..on-click @load-first-module
      ..html = @title
      @el._append ..

    super!

  /** @private */ title: window.'plaft'.'user'.'customs_agency'.'name'

/** @exports */
module.exports = Title

# vim: ts=2:sw=2:sts=2:et
