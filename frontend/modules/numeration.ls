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
    for stk in _dto.'stakeholders'
      delete stk.'slug'
    for declarant in _dto.'declarants'
      delete declarant.'slug'
    ########################################################################

    App.ajax._post "/api/dispatch/#{@model._id}/numerate", @el._toJSON!, do
      _success: ~>
        @_desktop.notifier.notify do
          _message : 'Se actualizó correctamente los datos'
          _type    : @_desktop.notifier.kSuccess
      _bad-request: ~>
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  _calculate-working-days: (d) ->
    if d isnt ''
      dt = d.split('/')
      _date = new Date (parseInt dt[2]), (parseInt dt[1])-1, (parseInt dt[0])
      days = 15
      while days
        _date.set-date _date.get-date! + 1
        if _date.get-day! not in [0, 6]
          days -= 1
      _day = _date.get-date!
      _day = if _day <= 9 then "0#{_day}" else "#{_day}"
      _month = _date.get-month! + 1
      _month = if _month <= 9 then "0#{_month}" else "#{_month}"
      @_last-day.html = "#{_day}/
                         #{_month}/
                         #{_date.get-full-year!}"
    else
      @_last-day.html = ''

  _calculate-storage-years: (d) ->
    if d isnt ''
      dt = d.split('/')
      @_five-years.html = "#{dt[0]}/
                           #{dt[1]}/
                           #{(parseInt dt[2])+5}"
    else
      @_five-years.html = ''

  _calculate-ammount-soles: (amount) ->
    _amount-soles = @el.query '#_ammount-soles'
    dollar = @el.query '[name=exchange_rate]' ._value
    if amount is '' or isNaN amount
      _amount-soles.html = ""
    else
      _amount-soles.html = "#{(parseFloat dollar)*(parseFloat amount)}"

  load-amount-soles: ~>
    _value = it._target._value
    @_calculate-ammount-soles _value

  load-dates: ~>
    ExpReg = /^(0?[1-9]|[12][0-9]|3[01])[\/](0?[1-9]|1[012])[/\\/](19|20)\d{2}$/
    _value = it._target._value
    if ExpReg.test _value
      @_calculate-working-days _value
      @_calculate-storage-years _value
    else
      @_last-day.html = ''
      @_five-years.html = ''


  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELDS
      ..render!
      .._free!
    @el._fromJSON @model._attributes

    _template = "
    <div class='#{gz.Css \form-group} #{gz.Css \col-md-12}'>
    <div class='#{gz.Css \form-group} #{gz.Css \col-md-4}'>
      <label class='#{gz.Css \col-md-12} #{gz.Css \control-label}'
             style='padding-left: 0px; padding-right: 0px;'>
      Monto en Soles
      </label></br>
      <label id='_ammount-soles'
             style='font-size: 20px; font-weight: 500;'></label>
    </div>
    <div class='#{gz.Css \form-group} #{gz.Css \col-md-4}'>
      <label class='#{gz.Css \col-md-12} #{gz.Css \control-label}'
             style='padding-left: 0px; padding-right: 0px;'>
      Último dia UIF
      </label></br>
      <label id='_last-days'
             style='font-size: 20px; font-weight: 500;'></label>
    </div>
    <div class='#{gz.Css \form-group} #{gz.Css \col-md-4}'>
      <label class='#{gz.Css \col-md-12} #{gz.Css \control-label}'
             style='padding-left: 0px; padding-right: 0px;'>
      Vigencia de RO 5 años
      </label></br>
      <label id='_five-years'
             style='font-size: 20px; font-weight: 500;'></label>
    </div>
    </div>
    "

    @$el._append _template

    @_five-years = @el.query '#_five-years'
    @_last-day = @el.query '#_last-days'


    _exchange-rate = @model._attributes.'exchange_rate'
    if not _exchange-rate or _exchange-rate is ''
      App.ajax._get '/utils/exchange_rate', do
        _success: (_res) ~>
          @el.query '[name=exchange_rate]' ._value = _res.'rate'

    @el.query '[name=numeration_date]'
      ..on-blur @load-dates
      @_calculate-working-days .._value
      @_calculate-storage-years .._value
    @el.query '[name=amount]'
      ..on-blur @load-amount-soles
      @_calculate-ammount-soles .._value
    super!

  _five-years: null
  _last-day: null

  /** Field list for numeration form. (Array.<FieldOptions>) */
  _FIELDS =
    * _name: 'dam'
      _label: 'N° Declaracion (DAM)'

    * _name: 'numeration_date'
      _label: 'Fecha numeración'

    * _name: 'amount'
      _label: 'Valor de la mercancia - FOB $'

    * _name: 'channel'
      _label: 'Canal - Tipo Aforo'
      _type: FieldType.kComboBox
      _options:
        'V'
        'N'
        'R'
    * _name: 'exchange_rate'
      _label: 'Tipo de cambio'
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
      'channel'

    _templates =
      'channel': ->
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
