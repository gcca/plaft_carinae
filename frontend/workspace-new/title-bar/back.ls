/** @module workspace */

/**
 * Back
 * ---------
 * Elemento para crear el botón Regresar.
 * @example
 * another-view._append (new Back).render!.el
 * @class Back
 * @extends View
 */
class Back extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \navbar-right} #{gz.Css \navbar-form}
             \ #{gz.Css \hidden}"

  _hide: -> @el._class._add gz.Css \hidden

  _show: -> @el._class._remove gz.Css \hidden

  /** @override */
  on-click: ~> @trigger gz.Css \back

  /** @override */
  render: ->
    @el.html = ''
    App.dom._new \button
      .._type = 'button'
      ..html = '&laquo; Regresar'
      .._class = "#{gz.Css \btn} #{gz.Css \btn-info}"
      ..on-click @on-click
      @el._append ..
    super!

/** @exports */
module.exports = Back

# vim: ts=2:sw=2:sts=2:et
