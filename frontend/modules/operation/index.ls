/** @module modules */

Module = require '../../workspace/module'
panelgroup = require '../../app/widgets/panelgroup'
  PanelGroup = ..PanelGroup
  PanelHeading = ..PanelHeading
  PanelHeadingClosable = ..PanelHeadingClosable
  PanelBody = ..PanelBody
  Testing = ..Testing
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
    pnl-group.new-panel new PanelBody, new PanelHeading
      .._panel-body._get-el!._append (new Customer _type: Customer.Type.kPerson).render!.el
      .._panel-heading.set-title-heading 'Declaracion jurada'

    pnl-group.new-panel new PanelBody, new PanelHeading
      .._panel-body._get-el!._append (new Dispatch).render!.el
      .._panel-heading.set-title-heading 'Despacho - Operacion'

    pnl-group.new-panel new PanelBody, new PanelHeading
      .._panel-body._get-el!._append (new Stakeholder).render!.el
      .._panel-heading.set-title-heading 'Vinculado'

    pnl-group.new-panel new PanelBody, new PanelHeading
      .._panel-body._get-el!._append (new Declarant).render!.el
      .._panel-heading.set-title-heading 'Declarante'

    pnl-group._set-array-for-panels!

    @el._append pnl-group.render!el
    super!

  /** @private  */ varible: null
  /** @protected*/ @@_caption = 'OPERACION'
  /** @protected*/ @@_icon    = gz.Css \cloud


/** @export */
module.exports = Operation


# vim: ts=2:sw=2:sts=2:et
