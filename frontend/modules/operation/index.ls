/** @module modules */

Module = require '../../workspace/module'
panelgroup = require '../../app/widgets/panelgroup'
  PanelGroup = ..PanelGroup
customer = require './customer'
  Customer = ..Customer
Dispatch = require './dispatch'
Stakeholder = require './stakeholder'
Declarant = require './declarant'


class OperationModel extends App.Model

  urlRoot: '/'


/**
 * Operation
 * ----------
 * TODO
 *
 * @class Operation
 * @extends Module
 */
class Operation extends Module

  on-search: (param) ~>
    alert 'se esta buscando ' + param

  on-save: ~>
    alert 'se esta guardando'
    @varible._panel-heading._change-button 0

  /** @override */
  render: ->
    @clean!
    pnl-group = new PanelGroup
    @varible = pnl-group.new-panel 'Declaración Jurada'
      .._body._append (new Customer _type: Customer.Type.kPerson).render!.el
    pnl-group.new-panel 'Despacho - Operacion'
      .._body._append (new Dispatch).render!.el
    pnl-group.new-panel 'Vinculado'
      .._body._append (new Stakeholder).render!.el
    pnl-group.new-panel 'Declarante'
      .._body._append (new Declarant).render!.el

    @el._append pnl-group.render!el
    super!

  /** @private  */ varible: null
  /** @protected*/ @@_caption = 'OPERACION'
  /** @protected*/ @@_icon    = gz.Css \cloud


/** @export */
module.exports = Operation


# vim: ts=2:sw=2:sts=2:et
