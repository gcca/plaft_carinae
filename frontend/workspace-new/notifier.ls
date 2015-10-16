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
 * Notification
 * ------------
 * @class Notification
 * @extends View
 * @private
 */
class Notification extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \alert} #{gz.Css \alert-dismissible}"

  /**
   * Remove notification.
   * @private
   */
  the-end: ~> @_free!

  /** @override */
  initialize: ({_message = '', \
                _type = (gz.Css \alert-info), \
                @_delay = 3000}) ->
    super!
    @el
      ..attr \role 'alert'
      .._class._add _type
      ..html = "<button type='button'
                    class='#{gz.Css \close}'
                    data-dismiss='alert'
                    aria-label='Close'
                    style='margin-left:10px'>
                  <span aria-hidden='true'>&times;</span>
                </button>
                <strong>Mensaje:</strong> &nbsp;&nbsp; #{_message}"
      ..css = 'position:fixed;
               bottom:0;
               margin-left:50%;
               padding:10px 17px'

  /** @private */ _delay: null

  /** @override */
  render: ->
    document.body._append @el
    setTimeout @the-end, @_delay
    super!


/**
 * Notifier (NotificationManager)
 * ------------------------------
 * Global and absolute notifier. (Single instance.)
 *
 * @example
 * >>> notifier = new Notifier
 * >>> notifier.notify 'Hello world!'  # info notification by default
 * >>> notifier.notify do  # type from class
 * ...   _message: 'Hello world!'
 * ...   _type: Notifier.kSuccess
 * >>> notifier.notify do  # type from object
 * ...   _message: 'Hello world!'
 * ...   _type: notifier.kSuccess
 * >>> notifier.notify do # with delay
 * ...   _message: 'Hello world!'
 * ...   _type: notifier.kSuccess
 * ...   _delay: 2000
 *
 *
 * @class Notifier
 */
class Notifier

  /**
   * Launch notification.
   * @param {string|Object<string,string,number>} {_message, _type, _delay}
   */
  notify: ->
    if it._constructor is String
      it = _message: it  # message to object with message
    else
      it._type = __2class it._type if it._type

    notification = Notification._new it
    notification.render!

  /** @constructor */
  ->
    if Notifier::__instance
      return Notifier::__instance
    else
      Notifier::__instance = @

  /** @private */ __instance: null

  /**
   * Enum value to alert class.
   * @private
   */
  __2class = ->
    switch it
      | @@kSuccess => gz.Css \alert-success
      | @@kInfo    => gz.Css \alert-info
      | @@kWarning => gz.Css \alert-warning
      | @@kDanger  => gz.Css \alert-danger
      | otherwise  => ''


  # Enum: notification type and access to Enum by object
  kSuccess : @@kSuccess = 1
  kInfo    : @@kInfo    = 2
  kWarning : @@kWarning = 4
  kDanger  : @@kDanger  = 8

/** @export */
module.exports = Notifier


# vim: ts=2:sw=2:sts=2:et
