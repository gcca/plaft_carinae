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
    sender-dto= _dto.'sender_stakeholders'
    reciever-dto =_dto.'reciever_stakeholders'
    if sender-dto?
      for sender in sender-dto
        @_pgStakeholder1.new-panel @_sender.'body'
          .._header._get panelgroup.ControlTitle ._text = @_sender.'title'
          .._body._json = sender

    if reciever-dto?
      for reciever in reciever-dto
        @_pgStakeholder2.new-panel  @_reciever.'body'
          .._header._get panelgroup.ControlTitle ._text = @_reciever.'title'
          .._body._json = reciever


  set-type: (_type) ->
    @render!
    if _type?
      if _type  # Entrada de mercaderia
        @_sender =
          'title': 'Importador'
          'body': CustomerBody
        @_reciever =
          'title': 'Destinatario'
          'body': LinkedBody
      else  # Salida de mercaderia
        @_sender =
          'title': 'Proveedor'
          'body': LinkedBody
        @_reciever =
          'title': 'Exportador'
          'body': CustomerBody

      @_pgStakeholder1.set-panel @_sender.'title', @_sender.'body'
      @_pgStakeholder2.set-panel @_reciever.'title', @_reciever.'body'

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
