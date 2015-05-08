/** @module modules.income */

/**
 * Pdf
 * --------------------
 * @example
 * >>> panel-pdf = new Pdf _title 'Example Title'
 * >>> panel-pdf._show do
 * >>>   _href: Refencia del PDF.
 * @class Pdf
 * @extends PanelHeading
 * @export
 */
class exports.Pdf extends App.widget.panelgroup.PanelHeading

  /**
   * Agrega el boton PDF en el panelHeader.
   * @param {String} _href
   */
  _show: ->
    @_span.html = ''
    _icon = App.dom._new \i
      .._class = "#{gz.Css \glyphicon}
                  \ #{gz.Css \glyphicon-bookmark}"

    _btn = App.dom._new \a
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-info}
                \ #{gz.Css \btn-sm}
                \ #{gz.Css \pull-right}"
      ..href = "#{it._href}"
      ..target = '_blank'
      ..html = 'PDF '
      .._append _icon

    @_span._append _btn
    @_span.css.\display = ''

  /** @override */
  render: ->
    ret = super!

    @_span = App.dom._new \span
      .._class = gz.Css \pull-right
      ..css= "flex:1;margin:5px;display:-webkit-inline-box"

    @_head._append @_span
    ret
