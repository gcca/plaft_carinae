/** @module workspace */


/**
 * Search
 * ------
 * Maybe it needs customization style after DOM appended.
 *
 * @example
 * >>> search = new Search
 * >>> external-container._append search.render!.el
 * >>> search.el._class._add ".your-custom-style"
 * >>> menu-items =
 * ...   * _caption: 'title 1'
 * ...     _label: 'menu-item 1'
 * ...     _value: 1
 * ...   * _caption: 'title 2'
 * ...     _label: 'menu-item 2'
 * ...     _value: 2
 * ...   ...
 * ...   * _caption: 'title n'
 * ...     _label: 'menu-item n'
 * ...     _value: n
 * >>> search._menu menu-items
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
      @trigger (gz.Css \search), @_input-query._value, \
                                 @_menu-current-value

  /**
   * (Event) On change dropdown value.
   * @param {Event} evt
   * @private
   */
  _on-change-value: (evt) ~>
    @menu-change-value evt._target._item

  /**
   * Change current menu value.
   * @param {Object} _item {_value, _label, _name}
   */
  menu-change-value: (_item) ->
    @_menu-caption.html = _item._caption
    @_menu-current-value = _item._value

  /**
   * Enable (disable) menu.
   * Menu is disabled when {@code _items} is {@code null}
   * or {@code undefined}.
   * @param {?Array<Object>} _items [{_value, _label, _name}]
   * @private
   */
  _menu: (_items) ->
    @_menu-dropdown.html = null  # clean dropdown
    if _items? and _items._length  # show menu
      for _item in _items
        _a = App.dom._new \a
          ..html = _item._label

        _li = App.dom._new \li
          .._item = _item
          ..on-click @_on-change-value
          .._append _a

        @_menu-dropdown._append _li

      @_group._append @_menu-btn
      @_group._append @_menu-dropdown

      # TODO: initial value from user data, divisions, and sub-menus.
      @menu-change-value _items.0  # value selected menu item
    else  # hide menu
      if @_menu-btn._parent?
        @_group._remove @_menu-btn
        @_group._remove @_menu-dropdown
        @_menu-dropdown.html = ''

  /**
   * Get focus on input query.
   * @param {?string} _message
   */
  _focus: (_message) ->
    @_input-query._focus!

    if _message?
      $ @_input-query ._popover do
        \title   : 'Buscador'
        \content : _message
        \placement : \bottom
      $ @_input-query ._popover \show
      setTimeout (~> $ @_input-query ._popover \destroy), 2500

  /** @override */
  render: ->
    @el.html = "<div class='#{gz.Css \form-group}'>
                  <div class='#{gz.Css \input-group}'>
                    <input type='text'
                           class='#{gz.Css \form-control}'
                           placeholder='Buscar'>
                    <span class='#{gz.Css \input-group-btn}
                               \ #{gz.Css \pull-left}'>
                      <button type='submit'
                              class='#{gz.Css \btn} #{gz.Css \btn-default}'>
                        &nbsp;
                        <i class='#{gz.Css \glyphicon}
                                \ #{gz.Css \glyphicon-search}'>
                        </i>
                        &nbsp;
                      </button>
                    </span>
                  </div>
                </div>"
    @_input-query = @el._first._first._first
    @_group = @el._first._first._last

    # dropdown elements
    @_menu-btn = App.dom._new \button
      .._type = \button
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}
                \ #{gz.Css \dropdown-toggle}"
      .._data.'toggle' = 'dropdown'
      ..html = "<span></span>
                &nbsp;&nbsp;
                <span class='#{gz.Css \caret}'></span>"
      @_menu-caption = .._first

    @_menu-dropdown = App.dom._new \ul
      .._class = "#{gz.Css \dropdown-menu} #{gz.Css \dropdown-menu-right}"
      ..css._left = '0'
      ..attr \role \menu

    @_menu-current-value = null  # clean menu current value
    super!


  /** @private */ _input-query: null  # input group
  /** @private */ _group: null  # input group
  /** @private */ _menu-btn: null  # button to dropdown
  /** @private */ _menu-dropdown: null  # dropdown list
  /** @private */ _menu-current-value: null # current selected option
  /** @private */ _menu-caption: null  # caption in button


/** @export */
module.exports = Search


# vim: ts=2:sw=2:sts=2:et
