/** @module workspace */


#_option = "
#  <div class='#{gz.Css \input-group}'>
#    <input type='text' class='#{gz.Css \form-control}'
#        placeholder='Buscar'>
#    <span class='#{gz.Css \input-group-btn}'>
#      <button class='#{gz.Css \btn} #{gz.Css \btn-default}'>
#        &nbsp;
#        <i class='#{gz.Css \glyphicon} #{gz.Css \glyphicon-search}'></i>
#        &nbsp;
#      </button>
#      <button type='button'
#          class='#{gz.Css \btn}
#               \ #{gz.Css \btn-default}
#               \ #{gz.Css \dropdown-toggle}'
#          data-toggle='dropdown' tabindex='-1'>
#        &nbsp;
#        <span class='#{gz.Css \caret}'></span>
#        <span class='#{gz.Css \sr-only}'>gz</span>
#        &nbsp;
#      </button>
#      <ul class='#{gz.Css \dropdown-menu} #{gz.Css \pull-right}'
#          role='menu'>
#        <li class='#{gz.Css \divider}'></li>
#        <li><a href='/signout'>Salir</a></li>
#        <li class='#{gz.Css \divider}'></li>
#      </ul>
#    </span>
#  </div>"


/**
 * Search
 * ------
 * Maybe it needs customization style after DOM appended.
 *
 * @example
 * >>> search = new Search
 * >>> external-container._append search.render!.el
 * >>> search.el._class._add ".you-custom-style"
 *
 * @class Search
 * @extends View
 */
class Search extends App.View

  /** @override */
  _tagName: \form

  /** @override */
  _className: "#{gz.Css \form-inline}"

  /** @override */
  _events:
    /**
     * Trigger search event.
     * @private
     */
    on-submit: (evt) ->
      evt.prevent!
      @trigger (gz.Css \search), @el._first._first._value

  /** @override */
  render: ->
    @el.html = "
      <div class='#{gz.Css \form-group}'>
        <input type='text'
            class='#{gz.Css \form-control}' placeholder='Buscar'>
      </div>
      <button type='submit'
          class='#{gz.Css \btn} #{gz.Css \btn-default}'>
        &nbsp;
        <i class='#{gz.Css \glyphicon} #{gz.Css \glyphicon-search}'></i>
        &nbsp;
      </button>"

    super!


/** @export */
module.exports = Search


# vim: ts=2:sw=2:sts=2:et
