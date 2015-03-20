/** @module modules */

class Modal extends App.View

  /** @override*/
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \modal} #{gz.Css \fade}"

  /** @override */
  _id: gz.Css \my-modal

  /** @private */
  _open: (_body, _title)->
    @body.html = _body
    if _title?
      @title.html = _title
    $ "##{@el._id}" .modal 'show'

  /** @private */
  _close: ~>
    $ "##{@el._id}" .modal 'hide'

  /** @override */
  render: ->
    @el.html = "<div class='#{gz.Css \modal-dialog}'>
                  <div class='#{gz.Css \modal-content}'>
                    <div class='#{gz.Css \modal-header}'>
                      <button type='button' class='#{gz.Css \close}'>
                        <span>
                          &times;
                        </span>
                      </button>
                      <h4 class='#{gz.Css \modal-title}'>
                       TITULO
                      </h4>
                    </div>
                    <div class='modal-body'>
                    </div>
                  </div>
                </div>"
    @title = @el.query 'h4'
    @body = @el.query '.modal-body'
    button = @el.query '.close'
    button.on-click @_close
    super!

  /** @private */ title: null
  /** @private */ body: null

/** @export */
module.exports = Modal


# vim: ts=2:sw=2:sts=2:et
