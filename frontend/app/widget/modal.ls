/** @module app.widget */

/*
 * @Class MessageBox
 * @extends View
 */
class Modal extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \modal}
             \ #{gz.Css \fade}"

  _free: ->
    @$el.modal 'hide'
    super!

  _show: (type=@@CLASS.none) ->
    @el._first._class._add type
    @$el.modal 'show'

  _hide: ->
    @$el.modal 'hide'

  /** @override */
  initialize: ({_title= '', \
                _body=''}) ->
    @el.html = "
      <div class='#{gz.Css \modal-dialog}'>
        <div class='#{gz.Css \modal-content}'>
          <div class='#{gz.Css \modal-header}'>
            <button type='button'
                    class='#{gz.Css \close}'
                    data-dismiss='modal'
                    aria-label='Close'>
              <span aria-hidden='true'>
                &times;
              </span>
            </button>
            <h4 class='#{gz.Css \modal-title}'>
              #{_title}
            </h4>
          </div>
          <div class='#{gz.Css \modal-body}'>
          </div>
          <div class='#{gz.Css \modal-footer}'>
          </div>
        </div>
      </div>"

    @_close  = @el.query ".#{gz.Css \close}"
    @_footer = @el.query ".#{gz.Css \modal-footer}"
    @_head   = @el.query ".#{gz.Css \modal-header}"
    @_body   = @el.query ".#{gz.Css \modal-body}"

    if typeof _body is 'string'
      @_body.html = _body
    else
      @_body._append _body

    @$el.on \hidden.bs.modal, ~>
      @$el._remove!


  @@CLASS =
    large : gz.Css \modal-lg
    small : gz.Css \modal-sm
    none  : null

  _callback: null
  _footer: null
  _head: null
  _body: null

class MessageBox extends Modal

  initialize: ({_title= '', \
                _body='', \
                _role=@@ROLE.kYesNo, \
                @_callback= ->}) ->
    _r = super do
      _title: _title
      _body: _body

    $ @_footer ._append _role

    @_footer
      .._first.on-click ~>
        @_callback off
        @_hide!

      .._last.on-click ~>
        @_callback on
        @_hide!
    _r


  # @see ROLE
  __pair-buttons = (_true, _false) ->
    "<button type='button'
             class='#{gz.Css \btn}
                  \ #{gz.Css \btn-default}'>#{_false}</button>
     <button type='button'
             class='#{gz.Css \btn}
                  \ #{gz.Css \btn-primary}'>#{_true}</button>"


  # Enum: notification type and access to Enum by object
  @@ROLE =
    kYesNo        : __pair-buttons 'Si'      'No'
    kAcceptCancel : __pair-buttons 'Aceptar' 'Cancelar'


/** @export */
exports <<<
  MessageBox: MessageBox
  Modal: Modal

# vim: ts=2:sw=2:sts=2:et
