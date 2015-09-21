/** @module modules */

Module = require '../../../workspace/module'

FieldType = App.builtins.Types.Field
Details = require './details'

/**
* @Class Billing
* @extends Module
*/
class Billing extends Module

  /** @override */
  _tagName: \form

  on-save: ~>
    App.ajax._post "/api/admin/billing", @_toJSON!, do
      _success: (billing) ~>
        @billing-id = billing.'id'

        @el.query ".#{gz.Css \btn-info}"
          ..attr 'href', "/api/admin/billing/#{@billing-id}"
          .._class._remove gz.Css \hidden

        @_desktop.notifier.notify do
          _message: 'Se registro correctamente'
          _type: @_desktop.notifier.kSuccess

      _bad-request: ->
        alert '(Error)'

  _toJSON: ->
    _r = @el._toJSON!
      ..'customs' = @customs-dto
      ..'method' = @method-item
      ..'id' = @billing-id
      .. <<< @details._toJSON!

  change-value: (item) ->
    @method-item = item
    @name-method.html = item

  dropdown-menu: ->
    ul-method = App.dom._new \ul
      .._class = gz.Css \dropdown-menu

    for k, i in METHODS
      _a = App.dom._new \a
        ..html = METHODS[i]

      _li = App.dom._new \li
        .._item = METHODS[i]
        ..on-click (evt) ~> @change-value evt._target._item
        .._append _a

      ul-method._append _li

    @change-value METHODS[0]
    ul-method

  change-customs-name: (name) ->
    @customs-dto = window.plaft.'customs'[name]
    @customs.html = "<strong>Dirección : </strong>&nbsp;&nbsp;
                     #{@customs-dto.'address'} <br/>
                     <strong>R.U.C : </strong>&nbsp;&nbsp;
                     #{@customs-dto.'document_number'}"

  customs-names: ->
    App.GLOBALS.update_customs!
    names = [c for c in Object.keys window.plaft.'customs']
    select-names = App.dom._new \select
      .._class = "#{gz.Css \form-control} #{gz.Css \select-customs}"
      ..on-change (evt) ~> @change-customs-name evt._target._value

    for n in names
      App.dom._new \option
        ..html = n
        select-names._append ..
    @change-customs-name names[0]
    select-names

  /** @override */
  render: ->
    # DESCRIPCION-LOGO
    logo = "<div class='#{gz.Css \col-md-6}'>
              <address class='#{gz.Css \text-center}'>
                <strong class='#{gz.Css \text-center}'
                        style='font-size: 25px'>
                  CAVASOFT S.A.C.
                </strong><br/>
                <strong style='font-size: 12px'>
                  COMERCIALIZACION DE SOFTWARE HARDWARE, SUMINISTROS,
                  SERVICIO TÉCNICO Y ASESORÍA.
                </strong><br/>
                CALLE VARSOVIA N 139 Of. 101 URB LOS SAUCES II -
              \ SURQUILLO <br/>
                LIMA 34 - PERU - TELEFAX: 449-6929 <br/>
                E.MAIL: <a>cesarvargas@cavasoft.com</a>
              \ - <a>www.cavasoftsac.com</a>
              </address>
            </div>"
    # CLIENTE
    place-customer = App.dom._new \div
      .._class = "#{gz.Css \col-md-12} #{gz.Css \no-padding}"

    App.dom._new \div
      .._class = "#{gz.Css \col-md-6} #{gz.Css \place-customer}
                \ #{gz.Css \bordered}"
      ..html = "<span class='#{gz.Css \col-md-12}'>
                  <strong>Nombres o Razón Social : </strong>&nbsp;&nbsp;
                </span>
                <span class='#{gz.Css \col-md-12}'></span>"
      @customs = .._last
      .._first._append @customs-names!
      place-customer._append ..

    # FECHA
    new Date
      day = ..get-date!
      month =  ..get-month!
      year = ..get-full-year!
    App.dom._new \div
      .._class = "#{gz.Css \col-md-6}  #{gz.Css \place-customer}"
      ..html = "<span class='#{gz.Css \col-md-4} #{gz.Css \text-center}'>
                  <label>FECHA</label>
                  <input type='text' name='date_bill'
                         value='#{day + '/' +
                               \ month + '/' +
                               \ year}'
                         class='#{gz.Css \form-control}' />
                </span>
                <span class='#{gz.Css \col-md-4} #{gz.Css \text-center}'>
                  <label>ORD./COMPRA</label>
                  <input type='text' name='purchase'
                         class='#{gz.Css \form-control}' />
                </span>
                <span class='#{gz.Css \col-md-4} #{gz.Css \text-center}'>
                  <label>VENDEDOR</label>
                  <input type='text' name='seller'
                         value= 'OFICINA'
                         class='#{gz.Css \form-control}' />
                </span>
                <span class='#{gz.Css \col-md-6} #{gz.Css \text-center}'>
                  <label>COND. PAGO</label>
                  <input type='text' name='payment'
                         value='CONTRAENTREGA'
                         class='#{gz.Css \form-control}' />
                </span>
                <span class='#{gz.Css \col-md-6} #{gz.Css \text-center}'>
                  <label>GUIA(S) N</label>
                  <input type='text' name='guide'
                         class='#{gz.Css \form-control}' />
                </span>"
      place-customer._append ..

    # NUMERO DE ORDEN
    place-order = App.dom._new \div
      .._class = "#{gz.Css \col-md-5}
                \ #{gz.Css \text-center}
                \ #{gz.Css \place-ruc}
                \ #{gz.Css \bordered}"
      ..html = "<strong>R.U.C. 20514448176</strong><br/>
                <strong></strong><br/>"
      place-method = .._first._next._next

    a-order = App.dom._new \a
      .._class = gz.Css \dropdown-toggle
      .._data.'toggle' = 'dropdown'
      ..html = "<span></span><b class='#{gz.Css \caret}'></b><br/>"
      @name-method = .._first

    App.dom._new \span
      .._class = gz.Css \dropdown
      .._append a-order
      .._append @dropdown-menu!

      place-method._append ..


    @details = new Details
    # AÑADIR
    @el.html = "<div class='#{gz.Css \col-md-12}'
                     style='margin-bottom: 15px'>
                  <a class='#{gz.Css \btn} #{gz.Css \btn-primary}
                          \ #{gz.Css \pull-right} '>
                    GUARDAR
                  </a>
                  <a class='#{gz.Css \btn} #{gz.Css \btn-info}
                          \ #{gz.Css \pull-right}'
                     target='_blank'>
                    IMPRIMIR
                  </a>
                </div>
                #{logo} <div class='#{gz.Css \col-md-1}'></div>"

    @el._append place-order
    @el._append place-customer

    @el._append @details.render!.el
    @el.query ".#{gz.Css \btn-primary}"
      ..on-click @on-save
    super!


  METHODS =
    'Boleta de Venta'
    'Factura'
    'Guia de remisión'
    'Nota crédito'
    'Nota de Abono'

  /** @private */ name-method: null
  /** @private */ customs: null
  /** @private */ customs-dto: null
  /** @private */ method-item: null
  /** @private */ details: null
  /** @private */ billing-id: null

  /** @protected */ @@_caption = 'FACTURACIÓN'
  /** @protected */ @@_icon    = gz.Css \usd
  /** @protected */ @@_hash    = ''

/** @export */
module.exports = Billing


# vim: ts=2:sw=2:sts=2:et
