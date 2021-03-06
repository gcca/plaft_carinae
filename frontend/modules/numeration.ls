/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */


Module = require '../workspace-new/module'
modal = App.widget.message-box
Modal = modal.Modal
table = App.widget.table
  Table = ..Table
FieldType = App.builtins.Types.Field


/**
 * NumerationEdit
 * --------
 * Una vista que contiene el formulario del modulo de Numeracion de registros
 * En esta vista solo se pueden modificar los datos de numeracion:
 * dam, numeration_date, canal, currency, exchange_rate, ammount_soles,
 * uif-last-day, expire-date-RO
 *
 * @class NumerationEdit
 * @extends Module
 */
class NumerationEdit extends Module

  /** @override */
  _tagName: \form

  /** @override */
  on-save: ~>
    @_desktop._spinner-start!

    _dto = @el._toJSON!
    App.ajax._post "/api/dispatch/#{@model._id}/numerate", _dto, do
      _success: ~>
        @model._set _dto  # update data for change on (event)

        @_desktop.notifier.notify do
          _message : 'Se actualizó correctamente los datos'
          _type    : @_desktop.notifier.kSuccess

        @_desktop._spinner-stop!

        if @model._attributes.'amount' > 10000
          $ (@el.query '.btn-success') ._hide!
          $ (@el.query '.btn-danger') ._hide!

      _bad-request: ~>
        alert 'ERROR: e746ae94-5a3a-11e4-9a1d-88252caeb7e8'

  /**
   * (Event) Accept dispatch (to operation).
   * @private
   */
  on-accept: ~>
    response-button = (_value) ~>
      if _value
        App.ajax._post "/api/dispatch/#{@model._id}/accept", null, do
          _success: ~>
            @_desktop.notifier.notify do
              _message : 'Se ha registrado como operación'
              _type    : @_desktop.notifier.kSuccess

            $ (@el.query '.btn-success') ._hide!
            $ (@el.query '.btn-danger') ._show!
          _bad-request: ~>
            alert 'DENEGADO (Error)'

    message = modal.MessageBox._new do
      _title: 'Registro de operación'
      _body: '<h5>¿Desea enviar a registro de operación?</h5>'
      _callback: response-button
    message._show!


  /**
   * (Event) Reject dispatch (to operation).
   * @private
   */
  on-reject: ~>
    App.ajax._post "/api/dispatch/#{@model._id}/reject", null, do
      _success: ~>
        delete @model._attributes.'operation'
        @_desktop.notifier.notify do
          _message : 'Se ha restauro.'
          _type    : @_desktop.notifier.kWarning

        $ (@el.query '.btn-success') ._show!
        $ (@el.query '.btn-danger') ._hide!
      _bad-request: ~>
        alert '(Error)'

  _calculate-working-days: (dt) ->
    if dt?
      array-date = dt
      if typeof dt is 'string'
        re-date = /^(\d{1,2})[\/-](\d{1,2})[\/-](\d{4})$/

        array-date = re-date.'exec' dt
        array-date._shift!

      _date = new Date (parseInt array-date[2]),
                       (parseInt array-date[1])-1,
                       (parseInt array-date[0])
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
      array-date = dt
      if typeof dt is 'string'
        if dt isnt ''
          re-date = /^(\d{1,2})[\/-](\d{1,2})[\/-](\d{4})$/
          array-date = re-date.'exec' dt
          array-date._shift!

      @_five-years-display.html = "#{array-date[0]}/
                                   #{array-date[1]}/
                                   #{(parseInt array-date[2])+5}"
    else
      @_five-years-display.html = ''

  _calculate-amount-soles: (amount, exchange-rate) ->
    _value = (parseFloat exchange-rate) * amount
    @_amount-display.html = if _value then _value.'toFixed' 2 else '-'

  load-amount-soles: ~>
    _amount = @_amount-el._value
    if (parseFloat _amount) > 10000
      $ (@el.query '.btn-success') ._hide!
      $ (@el.query '.btn-danger') ._hide!
    else
      $ (@el.query '.btn-success') ._show!
      $ (@el.query '.btn-danger') ._hide!

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

  check-dam: ~>
    if @_dam-el._value is ''
      return
    year-current = (new Date()).get-full-year!
    jcode = @model._attributes.'jurisdiction'.'code'
    rcode = @model._attributes.'regime'.'code'
    dam-array = @_dam-el._value._split '-'
    dam-model = "#{jcode}-#{year-current}-#{rcode}"
    dam-insert = "#{dam-array[0]}-#{dam-array[1]}-#{dam-array[2]}"
    if dam-insert isnt dam-model
      message-dam = ['<ul>']
      if dam-array[0] isnt jcode
        message-dam._push '<li><strong>Juridicción Aduana</strong>
                          \ no conforme VERIFICAR</li>'
      if dam-array[1] not in ["#{year-current - 1}", "#{year-current}"]
        message-dam._push '<li><strong>Año</strong>
                          \ no conforme VERIFICAR</li>'
      if dam-array[2] isnt rcode
        message-dam._push '<li><strong>Regimén Aduanero</strong>
                          \ no conforme VERIFICAR</li>'
      message-dam._push '</ul>'
      mdl-dam = Modal._new do
          _title: 'Advertencia'
          _body: message-dam._join  ''
      mdl-dam._show!

  _has-operation: (dispatch) ->
    if not dispatch.'operation'?
      $ (@el.query '.btn-success') ._show!
      $ (@el.query '.btn-danger') ._hide!
    else
      $ (@el.query '.btn-success') ._hide!
      $ (@el.query '.btn-danger') ._show!

  /** @override */
  render: ->
    App.builder.Form._new @el, _FIELDS

      @_dam-el = .._elements.'dam'._element
        ..on-blur @check-dam

      .._elements.'numeration_date'._element
        ..on-blur @load-dates

      @_amount-el = .._elements.'amount'._element
        ..on-blur @load-amount-soles

      @_exchange-rate-el = .._elements.'exchange_rate'._element
        ..on-blur @load-amount-soles

      ..render!
      .._free!

    @el._fromJSON @model._attributes

    _special-buttons = App.dom._new \div
      .._class = gz.Css \col-md-6
      ..html = "<div class='#{gz.Css \col-md-12}'>&nbsp;</div>"

    @el._append _special-buttons

    _btn-accept = App.dom._new \button
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-success}
                \ #{gz.Css \col-md-3}"
      .._type = 'button'
      ..css = 'width:290px'
      ..html = 'Opcional: Monto menor al Umbral para RO, <br> análisis Riesgo
              \ o perfil del cliente.'
      ..title = 'El sujeto obligado podrá establecer internamente umbrales
                \ menores para el RO, los que se podrán fijar en función al
                \ análisis de riesgo de las operaciones que realiza del sector
                \ económico, del perfil del cliente o algún otro criterio que
                \ determine'
      $ .. ._tooltip do
        'template': "<div class='#{gz.Css \tooltip}' role='tooltip'
                          style='min-width:175px'>
                       <div class='#{gz.Css \tooltip-arrow}'></div>
                       <div class='#{gz.Css \tooltip-inner}'></div>
                     </div>"
      ..on-click @on-accept
      _special-buttons._append ..

    _btn-reject = App.dom._new \button
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-danger}
                \ #{gz.Css \col-md-3}"
      .._type = 'button'
      ..html = 'Restaurar'
      ..on-click @on-reject
      _special-buttons._append ..

    _amount-id = App.utils.uid 'l'
    _last-day-id = App.utils.uid 'l'
    _five-years-id = App.utils.uid 'l'

    _template = "
      <div class='#{gz.Css \form-group} #{gz.Css \col-md-12}'>
        <a class='#{gz.Css \btn} #{gz.Css \btn-primary}'
           href='http://ww1.sunat.gob.pe/cl-at-ittipcam/tcS01Alias'
           target='_blank'>
         Ver Tipo de Cambio
        </a>
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

    @_amount-display = @el.query "##{_amount-id}"
    @_last-day-display = @el.query "##{_last-day-id}"
    @_five-years-display = @el.query "##{_five-years-id}"

    @model._attributes
      @_calculate-working-days ..'numeration_date'
      @_calculate-storage-years ..'numeration_date'

      @_calculate-amount-soles ..'amount', ..'exchange_rate'
      if ..'amount' > 10000
        $ (@el.query '.btn-success')._parent ._hide!
      else
        @_has-operation ..


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

  /** @protected */ @@_mod-caption = 'INGRESAR NUMERACIÓN'


/**
 * Numeration
 * ----------
 * @class Numeration
 * @extends Module
 */
class Numeration extends Module

  /** @override */
  on-search: (query) ->
    _flag = off
    for model in @_pending.models
      if query is model._attributes.'order'
        _flag = on
        break
    if _flag
        @_desktop.load-next-page(NumerationEdit, do
                                     model: model)
    else
      @_desktop.notifier.notify do
        _message: 'Número de orden inválido: ' + query
        _type: @_desktop.notifier.kWarning

  /** @override */
  render: ->
    @_desktop._lock!
    @_desktop._spinner-start!

    _labels =
      'Aduana'
      'N&ordm; Orden'
      'Rég.'
      'Razón social / Nombre'
      'N&ordm; DAM'
      'F. Numerac'
      'FOB US$'
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
      'amount': ->
        _class = if not it? then gz.Css \hidden
                 else ''
        "<span class='#{_class}'>
          #{(new String(it)).replace /(\d)(?=(\d{3})+\.)/g, "$1, "}
        </span>"

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
                                    max-width:27ch;
                                    text-align: left;'

    App.model.Dispatches._pending (dispatches) ~>
    # '/api/customs_agency/list_dispatches'
      @_pending = dispatches
      _table = new Table do
        _attributes: _attributes
        _labels: _labels
        _templates: _templates
        _column-cell-style: _column-cell-style
        on-dblclick-row: (evt) ~>
          @_desktop.load-next-page(NumerationEdit, do
                                   model: evt._target._model)

      _table.set-rows @_pending
      @_table = _table

      @el._append _table.render!.el
      @_desktop._unlock!
      @_desktop._spinner-stop!


    @_desktop._search._focus 'Buscar por orden de despacho.'
    super!

  /** @private */ _table: null
  /** @private */ _pending: null

  /** @protected */ @@_mod-caption = 'NUMERACIÓN DE OPERACIONES'
  /** @protected */ @@_mod-icon    = gz.Css \print
  /** @protected */ @@_mod-hash    = 'auth-hash-numeration'


/** @export */
module.exports = Numeration


/* vim: ts=2 sw=2 sts=2 et: */
