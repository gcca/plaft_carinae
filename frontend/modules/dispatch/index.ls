/** @module modules */

Module = require '../../workspace/module'
PanelGroup = require '../../app/widgets/panelgroup'
Customer = require './customer'
Dispatch = require './dispatch'
Declarant = require './customer/declarant'
Stakeholder = require './customer/stakeholder'

/**
 * Operation
 * ----------
 * TODO
 *
 * @class Operation
 * @extends Module
 */
class Operation extends Module

  /** @override */
  render: ->
    @clean!
    pnl-group = new PanelGroup
    pnl-group.new-panel 'Declaración Jurada'
      .._body._append (new Customer _type: Customer.Type.kBusiness).render!.el
    pnl-group.new-panel 'Despacho - Operacion'
      .._body._append (new Dispatch).render!.el
    pnl-group.new-panel 'Declarante'
      .._body._append (new Declarant).render!.el
    pnl-group.new-panel 'Vinculado'
      .._body._append (new Stakeholder).render!.el

    @el._append pnl-group.render!el
    super!

  /** @protected*/ @@_caption = 'OPERACION'
  /** @protected*/ @@_icon    = gz.Css \cloud


/** @export */
module.exports = Operation


# vim: ts=2:sw=2:sts=2:et
