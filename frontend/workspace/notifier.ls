/** @module workspace.desktop
 *  - - - - - - - - - -
 * |                   |
 * |                   |
 * |                   |
 * |___________________|
 * |   _notification   |
 * |___________________|
 *
 * To notification messages to users about module state.
 */

/**
 * TODO: Clean memory
 */
class Notification extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \alert} #{gz.Css \alert-dismissible}"

  /** @override */
  initialize: ->
    @el
      ..attr \role 'alert'
      .._class._add it._type-class
      ..html = "
        <button type='button'
                class='#{gz.Css \close}'
                data-dismiss='alert'
                aria-label='Close'
                style='margin-left:10px'>
          <span aria-hidden='true'>&times;</span>
        </button>
        <strong>Mensaje:</strong> &nbsp;&nbsp; #{it._message}"
      ..css = 'position:absolute;
               bottom:0px;
               margin-left:50%;
               padding:10px 17px'
    super!

  render: ->
    document.body._append @el
    setTimeout (~> @$el._remove!), 3000
    super!

class Notifier

  notify: (_type = @@kInfo, message = '') ->
    notification = new Notification do
      _type-class : __2class _type
      _message    : message
    notification.render!

  ->
    if Notifier::__instance
      Notifier::__instance
    else
      Notifier::__instance = @


  __2class = ->
    switch it
      | @@kSuccess => gz.Css \alert-success
      | @@kInfo    => gz.Css \alert-info
      | @@kWarning => gz.Css \alert-warning
      | @@kDanger  => gz.Css \alert-danger


  @@kSuccess = 1
  @@kInfo    = 2
  @@kWarning = 4
  @@kDanger  = 8


/** @export */
module.exports = Notifier


# vim: ts=2:sw=2:sts=2:et
