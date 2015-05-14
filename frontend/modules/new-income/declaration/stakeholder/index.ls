/** @module modules */

stakeholder = require './stakeholders'
LinkedBody = require './linked'
CustomerBody = require './customer'

panelgroup = App.widget.panelgroup

/**
 * PanelHeadingStakeholder
 * -----------------------
 * @class PanelHeadingStakeholder
 * @extends PanelHeadingClosable
 */
class StakeholderGroup extends panelgroup.JSONBody

  _json-getter: ->
    'sender_stakeholders': @_pgStakeholder1._toJSON!
    'reciever_stakeholders': @_pgStakeholder2._toJSON!

  _json-setter: (_dto) ->
    for d in _dto.'sender_stakeholders'
      _sender = @_pgStakeholder1.new-panel do
        _panel-head = stakeholder.StakeholderHeading
        _panel-body = CustomerBody
      _sender._body._json = d

    for d in _dto.'reciever_stakeholders'
      _reciever = @_pgStakeholder1.new-panel do
        _panel-head = stakeholder.StakeholderHeading
        _panel-body = LinkedBody
      _reciever._body._json = d


  set-type: (_type) ->
    @render!
    if _type?
      if _type  # Entrada de mercaderia
        @_pgStakeholder1.set-panel 'Importador', CustomerBody
        @_pgStakeholder2.set-panel 'Destinatario', LinkedBody

      else  # Salida de mercaderia
        @_pgStakeholder1.set-panel 'Proveedor', LinkedBody
        @_pgStakeholder2.set-panel 'Exportador', CustomerBody
    @_pgStakeholder1.new-panel!
    @_pgStakeholder2.new-panel!

  render: ->
    @el.html = null
    @_pgStakeholder1 = new stakeholder.Stakeholders
    @_pgStakeholder2 = new stakeholder.Stakeholders

    @el._append @_pgStakeholder1.render!.el
    @$el._append '<div><hr></div>'
    @el._append @_pgStakeholder2.render!.el
    super!

  /** @private */ _pgStakeholder1: null
  /** @private */ _pgStakeholder2: null
  /** @private */ _sender: null
  /** @private */ _reciever: null

/** @export */
module.exports = StakeholderGroup


# vim: ts=2:sw=2:sts=2:et
