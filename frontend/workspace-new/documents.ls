/** @module workspace */

Treeview = require '../modules/documents/treeview'


class Documents extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: gz.Css \pull-right

  /** @override */
  render: ->
    @el.css = 'margin-top:4px'
    App.dom._new \span
      ..css = 'padding:2px 4px;
               border-left:1px solid #ccc'
      @el._append ..
    App.dom._new \button
      .._type = 'button'
      ..html = 'LEGISLACIÓN'
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-xs}
                \ #{gz.Css \btn-default}"
      ..css = 'font-size:0.8em'
      ..on-click ~>
        _modal = new App.widget.message-box.Modal do
          _title: 'Legislación'
          _body: (new Treeview).render!.el
        _modal._body.style.'padding' = '0'
        _modal._footer.style.'display' = 'inline'
        _modal._show App.widget.message-box.Modal.CLASS.large
      @el._append ..
    super!


/** @export */
module.exports = Documents
