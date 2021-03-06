/** @module modules */

Module = require '../../../workspace-new/module'

FieldType = App.builtins.Types.Field
Details = require './details'
table = App.widget.table
  Table = ..Table


class CollectionBilling extends App.Collection

  model: App.Model


/**
* @Class Billing
* @extends Module
*/
class Billing extends Module

  /** @override */
  _tagName: \form

  /** @override */
  on-save: ~>
    App.ajax._post "/api/admin/billing", @_toJSON!, do
      _success: (billing) ~>
        dto = @_toJSON!
          ..'id' = billing.'id'
        @model._set dto
        @el.query ".#{gz.Css \btn-info}"
          ..attr 'href', "/api/admin/billing/#{@model._id}"
          .._class._remove gz.Css \hidden

        @_desktop.notifier.notify do
          _message: 'Se registro correctamente'
          _type: @_desktop.notifier.kSuccess

      _bad-request: ->
        alert '(Error)'

  _toJSON: ->
    _r = @el._toJSON!
      ..'customs_agency' = @customs-dto
      ..'method' = @method-item
      ..'id' = @model._id
      ..'is_service' = if ..'is_service' is \true then true else false
      .. <<< @details._toJSON!

  change-value: (item) ->
    @method-item = item
    @name-method.html = item

  dropdown-menu: ->
    ul-method = App.dom._new \ul
      .._class = gz.Css \dropdown-menu

    for k in METHODS
      App.dom._new \li
        .._item = k
        ..on-click (evt) ~> @change-value evt._target._item
        ..html = "<a>#{k}</a>"
        ul-method._append ..

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
      .._name = 'customs_agency[name]'
      ..on-change (evt) ~> @change-customs-name evt._target._value

    for n in names
      App.dom._new \option
        ..html = n
        select-names._append ..

    # Name por defecto
    @change-customs-name select-names._value
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

    # DESCRIPCION DE LA FACTURA
    new Date
      day = ..get-date!
      month =  (..get-month! + 1)
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

    # DETALLE DE LA FACTURA
    @details = new Details
    # AÑADIR
    @el.html = "<div class='#{gz.Css \col-md-12}'
                     style='margin-bottom: 15px'>
                  <a class='#{gz.Css \btn} #{gz.Css \btn-info}
                          \ #{gz.Css \pull-right} #{gz.Css \hidden}'
                     target='_blank'
                     href='/api/admin/billing/#{@model._id}'>
                    IMPRIMIR
                  </a>
                </div>
                #{logo} <div class='#{gz.Css \col-md-1}'></div>"

    @el._append place-order
    @el._append place-customer

    @el._append @details.render!.el

    if @model._id?
      @model._attributes
        ..'is_service' = String ..'is_service'
        @el._fromJSON ..
        @details.load-table ..'details'
        @change-customs-name ..'customs_agency'.'name'
      @el.query ".#{gz.Css \btn-info}"
          .._class._remove gz.Css \hidden

    super!


  METHODS =
    'Factura'
    'Boleta de Venta'
    'Guia de remisión'
    'Nota crédito'
    'Nota de Abono'

  /** @private */ name-method: null
  /** @private */ customs: null
  /** @private */ customs-dto: null
  /** @private */ method-item: null
  /** @private */ details: null

  /** @protected */ @@_mod-caption = 'GENERAR FACTURACIÓN'

class BillList extends Module

  /** @override */
  _tagName: \div

  /** @override */
  render: ->
    @_desktop._lock!
    @_desktop._spinner-start!

    _labels =
      'Nombre/Razón Social'
      'Dirección'
      'Fecha de Factura'
      'Monto Total'
      ''

    _attributes =
      'customs_agency.name'
      'customs_agency.address'
      'date_bill'
      'to_pay'

    _templates =
      'to_pay': (_value, _dto, _attr, _tr) ->
        _dto.'billing_type' +
        \ ((_value).to-fixed 2).replace /(\d)(?=(\d{3})+\.)/g, "$1, "


    _column-cell-style =
      'customs_agency.name': 'text-overflow:ellipsis;
                              white-space:nowrap;
                              overflow:hidden;
                              max-width:27ch;
                              text-align:left'

      'customs_agency.address': 'text-overflow:ellipsis;
                                 white-space:nowrap;
                                 overflow:hidden;
                                 max-width:27ch;
                                 text-align:left'

    App.ajax._get '/api/admin/list-billing', true, do
      _success: (dto) ~>
        _table = new Table do
          _attributes: _attributes
          _labels: _labels
          _templates: _templates
          _column-cell-style: _column-cell-style
          on-dblclick-row: (evt) ~>
            @_desktop.load-next-page(Billing, do
                                     model: evt._target._model)

        _table.set-rows new CollectionBilling dto

        @el.html = "<h3 class='#{gz.Css \text-center}'>
                      FACTURACIÓN
                    </h3>"

        new-customs = App.dom._new \button
          ..html = 'Agregar Nuevo Factura'
          .._class = "#{gz.Css \btn} #{gz.Css \btn-primary}"
          ..on-click ~> @_desktop.load-next-page(Billing, do
                                                 model: new App.Model)
          @el._append ..

        @el._append _table.render!.el
        @_desktop._unlock!
        @_desktop._spinner-stop!
    super!


  /** @protected */ @@_mod-caption = 'FACTURACIÓN'
  /** @protected */ @@_mod-icon    = gz.Css \usd
  /** @protected */ @@_mod-hash    = ''

/** @export */
module.exports = BillList


# vim: ts=2:sw=2:sts=2:et
