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
          .._header._get panelgroup.ControlTitle ._text = @_sender.'heading'
          .._body._json = sender

    if reciever-dto?
      for reciever in reciever-dto
        @_pgStakeholder2.new-panel  @_reciever.'body'
          .._header._get panelgroup.ControlTitle ._text = @_reciever.'heading'
          .._body._json = reciever


  set-type: (_type) ->
    @render!
    if _type?
      if _type  # Entrada de mercaderia
        @_sender =
          'heading': 'Importador'  # 'Importador'
          'body': CustomerBody
          'title': 'Importadores'
        @_reciever =
          'heading': 'Proveedor'  # 'Proveedor'
          'body': LinkedBody
          'title': 'Proveedores'
      else  # Salida de mercaderia
        @_sender =
          'heading': 'Destinatario de Embarque'  # 'Destinatario'
          'body': LinkedBody
          'title': 'Destinatarios de Embarque'
        @_reciever =
          'heading': 'Exportador'  # 'Exportador'
          'body': CustomerBody
          'title': 'Exportadores'

      @_pgStakeholder1.set-panel @_sender.'heading', @_sender.'body'
      @_pgStakeholder2.set-panel @_reciever.'heading', @_reciever.'body'

    @$el._append "<h3>#{if @_sender? then @_sender.'title' else ''}</h3>"
    @el._append @_pgStakeholder1.render!.el
    @$el._append '<div><hr></div>'
    @$el._append "<h3>#{if @_reciever? then @_reciever.'title'  else  ''}</h3>"
    @el._append @_pgStakeholder2.render!.el

  render: ->
    @el.html = null
    @_pgStakeholder1 = new stakeholder.Stakeholders
    @_pgStakeholder2 = new stakeholder.Stakeholders
    super!

  /** @private */ _pgStakeholder1: null
  /** @private */ _pgStakeholder2: null
  /** @private */ _sender: null
  /** @private */ _reciever: null

/** @export */
module.exports = StakeholderGroup


# vim: ts=2:sw=2:sts=2:et
