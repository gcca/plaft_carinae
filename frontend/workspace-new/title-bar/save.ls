/** @module workspace */

class Save extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \navbar-right} #{gz.Css \navbar-form}"

  /** ocultar widget*/
  _hide: -> @el._class._add gz.Css \hidden

  /** mostrar widget*/
  _show: -> @el._class._remove gz.Css \hidden

  /** @override */
  on-click: ~> @trigger gz.Css \save

  /** @override */
  render: ->
    @el.html = ''
    App.dom._new \button
      .._type = 'button'
      ..html = 'Guardar'
      .._class = "#{gz.Css \btn} #{gz.Css \btn-primary}"
      ..on-click @on-click
      @el._append ..
    super!

/** @exports */
module.exports = Save
