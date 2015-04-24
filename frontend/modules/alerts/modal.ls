/** @module modules */

##########################################
# FALTA INTEGRAR A LAS ALERTAS.
##########################################


class Modal extends App.View

  /** @override*/
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \modal} #{gz.Css \fade}"

  /** @override */
  _id: gz.Css \my-modal

  /** @private */
  _open: (_body, _title)->
    @body.html = ""
    $ @body ._append _body
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
                    <div class='#{gz.Css \modal-body}'>
                    </div>
                  </div>
                </div>"
    @title = @el.query ".#{gz.Css \modal-title}"
    @body = @el.query ".#{gz.Css \modal-body}"
    close = @el.query '.close'
    close.on-click @_close
    super!

  /** @private */ title: null
  /** @private */ body: null

/** @export */
module.exports = Modal


# vim: ts=2:sw=2:sts=2:et
