/** @module workspace */

/**
 * Items
 * ------
 * Utilizado para el llenado de un DropDown menu.
 *
 * @example
 * >>> item = new Items list-filter: Lista de Valores.
 * >>> external-container._append item.render!.el
 *
 * @class Items
 * @extends View
 */

class Items extends App.View
  /** @override */
  _tagName: \ul

  /** @override */
  _className: "#{gz.Css \dropdown-menu}"

  /**
   * Add new list item.
   * @param {options-module} module
   * @return {HTMLElement} <li> element for search.
   * @private
   */
  _add: (filter) ->
    a = App.dom._new \a
      ..html = "#{filter._name}"

    li = App.dom._new \li
      ..on-click ~> @trigger (gz.Css \icon), filter._label, filter._value
      .._append a

  /** @override */
  initialize: ({@list-filter}) -> super!

  /** @override */
  render: ->
    for filter in @list-filter
      @el._append @_add filter
    super!

  /** @private */ list-filter: null



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
      @trigger (gz.Css \search), @el._first._first._value, \
                                 @_filter

  /**
   * Asigna lista procedente del modulo.
   * @param {Module} module
   * @example
   * @private
   */
  load-module: (module) ->
    if module._list-filter?
      @render-filter module._list-filter
    else
      @_dropdown.html = ""

  /**
   * Change name from DropDown.
   * @param {String} _label
   * @param {Integer} _value
   * @private
   */
  _change-value: (_label, _value) ~>
    content = @el.query '.content'
    content.html = _label
    @_filter = _value

  /**
   * Render for filter.
   * @param {Object} _module-list
   * @private
   */
  render-filter: (_module-list) ->
    $ @_dropdown ._append "<button class='#{gz.Css \btn}
                                        \ #{gz.Css \btn-default}
                                        \ #{gz.Css \dropdown-toggle}'
                                   type='button'
                                   data-toggle='dropdown'
                                   aria-expanded='false'>
                             <span class='#{gz.Css \content}'>
                              <i class='#{gz.Css \glyphicon}
                                      \ #{gz.Css \glyphicon}-\
                                        #{gz.Css \share}'></i>
                             </span>&nbsp;&nbsp;
                             <span class='#{gz.Css \caret}'></span>
                           </button>"
    new Items list-filter: _module-list
      ..on (gz.Css \icon), @_change-value
      @_dropdown._append ..render!.el


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
      </button>
      &nbsp;
      <div class='#{gz.Css \form-group} #{gz.Css \dropdown}'></div>"
    @_dropdown = @el.query '.dropdown'
    super!


/** @export */
module.exports = Search


# vim: ts=2:sw=2:sts=2:et
