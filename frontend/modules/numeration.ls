/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */


Module = require '../workspace/module'
modal = App.widget.message-box
Modal = modal.Modal
table = App.widget.table
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
    # TODO: Remove deprecated code
    _dto = @model._attributes
    for stk in _dto.'stakeholders'
      delete stk.'slug'
    ########################################################################

    _dto = @el._toJSON!
    App.ajax._post "/api/dispatch/#{@model._id}/numerate", _dto, do
      _success:     ~>
        @model._set _dto  # update data for change on (event)
        @_desktop.notifier.notify do
          _message : 'Se actualizó correctamente los datos'
          _type    : @_desktop.notifier.kSuccess
      _bad-request: ~>
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  _calculate-working-days: (dt) ->
    if dt?
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
      @_last-day-display.html = "#{_day}/
                         #{_month}/
                         #{_date.get-full-year!}"
    else
      @_last-day-display.html = ''

  _calculate-storage-years: (dt) ->
    if dt?
      @_five-years-display.html = "#{dt[0]}/
                           #{dt[1]}/
                           #{(parseInt dt[2])+5}"
    else
      @_five-years-display.html = ''

  _calculate-amount-soles: (amount, exchange-rate) ->
    _value = (parseFloat exchange-rate) * (parseFloat amount)
    @_amount-display.html = if _value then _value.'toFixed' 2 else '-'

  load-amount-soles: ~>
    _amount = @_amount-el._value
    _exchange-rate = @_exchange-rate-el._value
    @_calculate-amount-soles _amount, _exchange-rate

  load-dates: ~>
    re-date = /^(\d{1,2})[\/-](\d{1,2})[\/-](\d{4})$/
    date-array = re-date.'exec' it._target._value
    if date-array?
      date-array._shift!
      @_calculate-working-days date-array
      @_calculate-storage-years date-array
    else
      @_last-day-display.html = ''
      @_five-years-display.html = ''


  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELDS

      .._elements.'numeration_date'._element
        ..on-blur @load-dates

      @_amount-el = .._elements.'amount'._element
        ..on-blur @load-amount-soles

      @_exchange-rate-el = .._elements.'exchange_rate'._element
        ..on-blur @load-amount-soles

      ..render!
      .._free!

    @el._fromJSON @model._attributes

    _amount-id = App.utils.uid 'l'
    _last-day-id = App.utils.uid 'l'
    _five-years-id = App.utils.uid 'l'

    _template = "
      <div class='#{gz.Css \form-group} #{gz.Css \col-md-12}'>
        <button type='button' class='#{gz.Css \btn}
                                   \ #{gz.Css \btn-primary}'>
          Ver Tipo de Cambio
        </button>
      </div>
      <div class='#{gz.Css \form-group} #{gz.Css \col-md-12}'
           style='margin-top:1em'>
        <div class='#{gz.Css \form-group} #{gz.Css \col-md-4}'>
          <label class='#{gz.Css \col-md-12} #{gz.Css \control-label}'
                 style='padding-left:0;
                        padding-right:0;'>
            Monto en Soles
          </label>
          </br>
          <label id='#{_amount-id}'
                 style='font-size:20px;
                        font-weight:500;'>
          </label>
        </div>
        <div class='#{gz.Css \form-group} #{gz.Css \col-md-4}'>
          <label class='#{gz.Css \col-md-12} #{gz.Css \control-label}'
                 style='padding-left:0;
                        padding-right:0;'>
            Último dia UIF
          </label>
          </br>
          <label id='#{_last-day-id}'
                 style='font-size:20px;
                        font-weight:500;'>
          </label>
        </div>
        <div class='#{gz.Css \form-group} #{gz.Css \col-md-4}'>
          <label class='#{gz.Css \col-md-12} #{gz.Css \control-label}'
                 style='padding-left:0;
                        padding-right:0;'>
            Vigencia de RO 5 años
          </label>
          </br>
          <label id='#{_five-years-id}'
                 style='font-size:20px;
                        font-weight:500;'>
          </label>
        </div>
      </div>"

    @$el._append _template

    button = @el.query ".#{gz.Css \btn-primary}"

    button.on-click ~>
        _iframe = App.dom._new \iframe
          ..src = 'http://ww1.sunat.gob.pe/cl-at-ittipcam/tcS01Alias'
          ..width = '850px'
          ..height = '350px'
          ..css = 'border:none'
        mdl = Modal._new do
            _title: 'Ver tipo de cambio.'
            _body: _iframe
        mdl._show Modal.CLASS.large

    @_amount-display = @el.query "##{_amount-id}"
    @_last-day-display = @el.query "##{_last-day-id}"
    @_five-years-display = @el.query "##{_five-years-id}"

    @model._attributes
      @_calculate-working-days ..'numeration_date'
      @_calculate-storage-years ..'numeration_date'

      @_calculate-amount-soles ..'amount', ..'exchange_rate'

    super!

  /** @private */ _amount-el: null
  /** @private */ _exchange-rate-el: null
  /** @private */ _amount-display: null
  /** @private */ _last-day-display: null
  /** @private */ _five-years-display: null

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
      'Aduana'
      'Orden N&ordm;'
      'Régimen'
      'Razón social / Nombre'
      'N&ordm; DAM'
      'F. Numerac'
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
        ## if _label-type is ''
          ##################################################################
          # TODO: Crear métodos de debugging
          ##################################################################
          # 'CANAL VACIO'

        "<span class='#{gz.Css \label} #{_label-type}'>
           #{it}
         </span>"

    _column-cell-style =
      'declaration.customer.name': 'text-overflow:ellipsis;
                                    white-space:nowrap;
                                    overflow:hidden;
                                    max-width:27ch'

    App.ajax._get '/api/customs_agency/list_dispatches', do
      _success: (dispatches) ~>
        _pending = new Dispatches dispatches.'pending'
        _table = new Table  do
          _attributes: _attributes
          _labels: _labels
          _templates: _templates
          _column-cell-style: _column-cell-style
          on-dblclick-row: (evt) ~>
            @_desktop.load-next-page(NumerationEdit,
                                     model: evt._target._model)

        _table.set-rows _pending

        @el._append _table.render!.el

      _error: ->
        alert 'Error!!! Numeration list'

    super!

  /** @protected */ @@_caption = 'NUMERACIÓN'
  /** @protected */ @@_icon    = gz.Css \print
  /** @protected */ @@_hash    = 'NUM-HASH'


/** @export */
module.exports = Numeration


/* vim: ts=2 sw=2 sts=2 et: */
