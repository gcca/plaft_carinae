/** @module modules.income */

panelgroup = require '../../app/widgets/panelgroup'

class exports.ControlPDF extends App.View

  @@__hash__ = 'pdf'

  _tagName: \span

  _className: gz.Css \pull-right

  _show: (_href) ->
    @_pdf.attr \href _href
    @el.css.'display' = ''

  initialize: ({_heading}) ->
    @el.css = 'flex:1;margin:5px;display:-webkit-inline-box;'
    _icon = App.dom._new \i
      .._class = "#{gz.Css \glyphicon}
                  \ #{gz.Css \glyphicon-bookmark}"

    @_pdf = App.dom._new \a
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-info}
                \ #{gz.Css \btn-sm}
                \ #{gz.Css \pull-right}"
      ..target = '_blank'
      ..html = 'PDF '
      .._append _icon
    @el._append @_pdf

  _pdf: null

class exports.HeadingPDF extends panelgroup.PanelHeading

  _controls: [panelgroup.ControlTitle, ControlPDF]

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
#class exports.Pdf extends App.widget.panelgroup.PanelHeading

#  /**
#   * Agrega el boton PDF en el panelHeader.
#   * @param {String} _href
#   */
#  _show: ->
#    @_span.html = ''
#    _icon = App.dom._new \i
#      .._class = "#{gz.Css \glyphicon}
#                  \ #{gz.Css \glyphicon-bookmark}"

#    _btn = App.dom._new \a
#      .._class = "#{gz.Css \btn}
#                \ #{gz.Css \btn-info}
#                \ #{gz.Css \btn-sm}
#                \ #{gz.Css \pull-right}"
#      ..href = "#{it._href}"
#      ..target = '_blank'
#      ..html = 'PDF '
#      .._append _icon

#    @_span._append _btn
#    @_span.css.\display = ''

#  /** @override */
#  render: ->
#    ret = super!

#    @_span = App.dom._new \span
#      .._class = gz.Css \pull-right
#      ..css= "flex:1;margin:5px;display:-webkit-inline-box"

#    @_head._append @_span
#    ret
