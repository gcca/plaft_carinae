/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../workspace/module'

FieldType = App.builtins.Types.Field


class Dispatches extends App.Collection

  urlRoot: \dispatch

class NumerationEdit extends Module

  /** @override */
  _tagName: \form

  /** @override */
  on-save: ~>
    @model._save @el._toJSON!, do
      _success: ->
        console.log 'FIN'
      _error: ->
        console.log 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELDS
      .._class gz.Css \col-md-6
      ..render!
      .._free!
    @el._fromJSON @model._attributes

    super!

  /** Field list for numeration form. (Array.<FieldOptions>) */
  _FIELDS =
    * _name: 'dam'
      _label: 'N° Declaracion (DAM)'

    * _name: 'numeration_date'
      _label: 'Fecha numeración'

    * _name: 'amount'
      _label: 'Valor de la mercancia - FOB $'

    * _name: 'currency'
      _label: 'Tipo de moneda'
      _type: FieldType.kComboBox
      _options: <[Dólar]>

    * _name: 'exchange_rate'
      _label: 'Tipo de cambio'




class Dispatch extends App.Model

  urlRoot: 'dispatch/numeration'


class DispatchLobby extends App.View

  /** @override */
  _tagName: \table

  /** @override */
  _className: "#{gz.Css \table} #{gz.Css \table-hover}"

  /**
   * (Event) Load dispath clicked from list.
   * @param {Event} evt
   * @private
   */
  load-dispatch: (evt) ~>
    @_desktop.load-next-page NumerationEdit, model: evt._target.row-model

  _sanity: -> if it? then it else ''

  /**
   * Add dispatch to list.
   * @param {Object} dispatch DTO.
   * @return HTMLTableRowElement
   * @private
   */
  add-row: (dispatch) ->
    blank-code-name =
      'code': ''
      'name': ''
    dispatch.'jurisdiction' ?= blank-code-name
    dispatch.'regime' ?= blank-code-name

    App.dom._new \tr
      ..html = "
        <td>#{@_sanity dispatch.'jurisdiction'.'code'}</td>
        <td>#{@_sanity dispatch\order}</td>
        <td>#{@_sanity dispatch.'regime'.'code'}</td>
        <td>#{@_sanity dispatch.'customer'.'name'}</td>
        <td>#{@_sanity dispatch.'dam'}</td>
        <td>#{@_sanity dispatch.'numeration_date'}</td>
        <td>#{@_sanity dispatch.'amount'}</td>
      "
      ..on-dbl-click @load-dispatch
      ..row-model = new Dispatch dispatch

  /** @override */
  initialize: ({@_desktop}) -> super!

  /** @override */
  render: ->
    t-head = App.dom._new \thead
      ..html = "
        <tr>
          <th style='border-bottom:none'>Jurisdiccón</th>
          <th style='border-bottom:none'></th>
          <th style='border-bottom:none'>Régimen</th>
          <th style='border-bottom:none'>Cliente</th>
          <th style='border-bottom:none' colspan='2'>
            Declaración Aduanera Mercancía
          </th>
          <th style='border-bottom:none'>Valor</th>
        </tr>
        <tr>
          <th style='border-top:none'>Aduana</th>
          <th style='border-top:none'>N Orden</th>
          <th style='border-top:none'>Aduana</th>
          <th style='border-top:none'>Razón social / Nombre</th>
          <th style='border-top:none'>N</th>
          <th style='border-top:none'>Fecha</th>
          <th style='border-top:none'>FOB $</th>
        </tr>
      "

    t-body = App.dom._new \tbody

    # TODO: Improve sync for new dispatch:
    #   plot: for dto in window.'plaft'\ds

    dispatches = new Dispatches
    dispatches._fetch do
      # TODO: Use model array, don't object array.
      _success: (_, dtos) ~>
        for dto in dtos
          t-body._append @add-row dto

      _error: ->
        alert 'ERROR!!!! Numeration list'

    @el._append t-head
    @el._append t-body

    super!


  /** @private */ _desktop: null


class Numeration extends Module

  /** @override */
  render: ->
    @el._append (new DispatchLobby _desktop: @_desktop).render!.el
    super!


  /** @protected */ @@_caption = 'NUMERACIÓN'
  /** @protected */ @@_icon    = gz.Css \print


/** @export */
module.exports = Numeration


/* vim: ts=2 sw=2 sts=2 et: */
