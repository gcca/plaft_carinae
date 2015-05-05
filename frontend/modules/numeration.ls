/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../workspace/module'
table = require '../app/widgets/table'
  Table = ..Table
FieldType = App.builtins.Types.Field

/**
* @class Dispatch
* @extends Model
*/
class Dispatch extends App.Model
  urlRoot: 'dispatch'

/**
* @Class Dispatches
* @extends Collection
*/
class Dispatches extends App.Collection
  model: Dispatch

/**
 * Una vista que contiene el formulario del modulo de Numeracion de registros
 * En esta vista solo se pueden modificar los datos de numeracion:
 * dam, numeration_date, canal, currency, exchange_rate, ammount_soles,
 * uif-last-day, expire-date-RO
 *
 * @class NumerationEdit
 * @extends Module
 * @export
 */
class NumerationEdit extends Module

  /** @override */
  _tagName: \form

  /** @override */
  on-save: ~>
    ########################################################################
    # VER ON-SAVE DE OPERATION.LS
    _dto = @model._attributes
    for linked in _dto.'linked'
      delete linked.'slug'
    for declarant in _dto.'declarant'
      delete declarant.'slug'
    ########################################################################

    App.ajax._post "/api/dispatch/#{@model._id}/numerate", @el._toJSON!, do
      _success: ~>
        @_desktop.notifier.notify do
          _message : 'Se actualizó correctamente los datos'
          _type    : @_desktop.notifier.kSuccess
      _bad-request: ~>
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELDS
      .._class = gz.Css \col-md-6
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

    * _name: 'canal'
      _label: 'Canal - Tipo Aforo'
      _type: FieldType.kComboBox
      _options:
        'V'
        'N'
        'R'

    * _name: 'exchange_rate'
      _label: 'Tipo de cambio'

    * _name: 'ammount_soles'
      _label: 'Monto operacion Nuevos soles'

    * _name: 'uif_last_day'
      _label: 'UIF OS Ultimo dia'

    * _name: 'expire_date_RO'
      _label: 'Vigencia RO 5 años'

/**
 * @class Numeration
 * @extends Module
 */
class Numeration extends Module

  /** @override */
  render: ->
    _labels =
      'J. Aduana'
      'N Orden'
      'R. Aduana'
      'Razon social'
      'N DAM'
      'Fecha numeracion'
      'FOB $'
      'Canal'

    _attributes =
      'jurisdiction.code'
      'order'
      'regime.code'
      'declaration.customer.name'
      'dam'
      'numeration_date'
      'amount'
      'canal'

    _templates =
      'canal': ->
        _label-type = if it is 'V' then gz.Css \label-success
                      else if it is 'N' then gz.Css \label-warning
                      else if it is 'R' then gz.Css \label-danger
                      else ''
        if _label-type is ''
          ##################################################################
          # TODO: Crear métodos de debugging
          ##################################################################
          console.log 'CANAL VACIO'  # vale.

        "<span class='#{gz.Css \label} #{_label-type}'>
           #{it}
         </span>"

    App.ajax._get '/api/customs_agency/list_dispatches', do
      _success: (dispatches) ~>
        _pending = new Dispatches dispatches.'pending'
        _tabla = new Table  do
                      _attributes: _attributes
                      _labels: _labels
                      _templates: _templates
                      on-dblclick-row: (evt) ~>
                        @_desktop.load-next-page NumerationEdit, model: evt._target._model

        _tabla.set-rows _pending

        @el._append _tabla.render!.el


      _error: ->
        alert 'Error!!! Numeration list'

    super!


  /** @protected */ @@_caption = 'NUMERACIÓN'
  /** @protected */ @@_icon    = gz.Css \print


/** @export */
module.exports = Numeration


/* vim: ts=2 sw=2 sts=2 et: */
