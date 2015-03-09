/** @module modules */

panelgroup = require '../../../app/widgets/panelgroup'
  PanelGroup = ..PanelGroup
  PanelHeadingClosable = ..PanelHeadingClosable
  PanelHeadingDeclarant = ..PanelHeadingDeclarant
  PanelBody = ..PanelBody
Declarant = require './declarant'

/**
 * Declarants
 * ----------
 * TODO
 *
 * @class Declarants
 * @extends View
 */
class Declarants extends PanelGroup

  /** @override */
  _tagName: \div

  overload-new-panel: ~>
    @new-panel(new PanelBody, new PanelHeadingDeclarant)
    @_set-array-for-panels!

  /** @override */
  initialize: ->
    super ConcretPanel: Declarant

  /**
   *
   *
   * TODO: SEARCH FOR FUNCTION REMOVE ATTR
   * @override
   */
  render: ->
    @$el.removeAttr('class')
    @$el.removeAttr('id')

    @el.html = "<div></div>
                <button type='button'
                        class= '#{gz.Css \btn}
                              \ #{gz.Css \btn-default}'>
                  Agregar
                </button>"
    @root-el = @el._first
    @el._last.on-click @overload-new-panel

    super!

/** @export */
module.exports = Declarants


# vim: ts=2:sw=2:sts=2:et
