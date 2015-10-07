/** @module workspace */

/**
 * Module
 * ------
 * Module base class.
 * Only for module inheritance.
 *
 *
 * @class Module
 * @extends View
 */
class Module extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \col-md-12}
             \ #{gz.Css \no-select}
             \ #{gz.Css \module}"

  /**
   * (Event) On search from global search form.
   * @param {string} query
   * @param {string} type
   * @protected
   */
  on-search: (query, filter) ->

  /**
   * (Event) On save from global button.
   * @protected
   */
  on-save: ->

  /**
   * Clean before new render.
   * @protected
   */
  clean: -> @el.html = ''

  /** @override */
  initialize: ->
    @clean!

  /** @protected */ _desktop: null
  /** @protected */ _parent: null

  /** @protected */ @@_mod-search-menu = null
  /** @protected */ @@_mod-caption     = ''
  /** @protected */ @@_mod-icon        = ''
  /** @protected */ @@_mod-hash        = ''
  /** @protected */ @@_mod-group-buttons = null


/** @export */
module.exports = Module


# vim: ts=2:sw=2:sts=2:et
