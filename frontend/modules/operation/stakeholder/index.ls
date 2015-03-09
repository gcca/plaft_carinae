/** @module modules */

Stakeholder = require './stakeholder'

panelgroup = require '../../../app/widgets/panelgroup'
  PanelGroup = ..PanelGroup
  PanelHeadingStakeHolder = ..PanelHeadingStakeHolder
  PanelBody = ..PanelBody

/**
 * Stakeholders
 * ----------
 * TODO
 *
 * @class Stakeholders
 * @extends View
 */

class Stakeholders extends PanelGroup

  /** @override */
  _tagName: \div

  overload-new-panel: ~>
    @new-panel(new PanelBody, new PanelHeadingStakeHolder)
    @_set-array-for-panels!

  /*
   *
   * TODO
   * @private
   */
  /** @override */
  initialize: ->
    super ConcretPanel: Stakeholder


  /** @override */
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
module.exports = Stakeholders


# vim: ts=2:sw=2:sts=2:et
