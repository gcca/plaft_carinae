/** @module workspace */

Title = require './title'
Search = require './search'
Save = require './save'
Back = require './back'


/**
 * TitleBar
 * ---------
 * Elemento para crear el title-bar
 * @example
 * another-view._append (new TitleBar).render!.el
 * @class TitleBar
 * @extends View
 */
class TitleBar extends App.View

  /** @override */
  _tagName: \header

  /** @override */
  _className: "#{gz.Css \navbar}
             \ #{gz.Css \navbar-inverse}
             \ #{gz.Css \navbar-fixed-top}"

  /** @override */
  render: ->
    @el.attr 'role', 'banner'
    container = App.dom._new \div
      .._class = gz.Css \container

    @search = new Search
    @save = new Save
    @back = new Back
    ## TITLE
    @title = new Title
      container._append ..render!.el

    nav = App.dom._new \nav
      .._class = "#{gz.Css \collapse} #{gz.Css \navbar-collapse}"
      ..attr 'role', 'navigation'

    ## SETTINGS
    ul = App.dom._new \ul
      .._class = "#{gz.Css \nav} #{gz.Css \navbar-nav}"
      nav._append ..

    ## SAVE
    nav._append @save.render!.el

    ## SEARCH
    App.dom._new \div
      .._class = "#{gz.Css \navbar-right}"
      ..attr 'role', 'search'
      ..id = gz.Css \search
      .._append @search.render!.el
      nav._append ..

    ## BACK
    nav._append @back.render!.el

    container._append nav

    @el._append container

    super!

  /** @public */ title: null
  /** @public */ save: null
  /** @public */ search: null
  /** @public */ back: null

/** @exports */
module.exports = TitleBar


# vim: ts=2:sw=2:sts=2:et
