/** @module modules */

table = App.widget.table
  Table = ..Table


class CollectionDetail extends App.Collection

  model: App.Model

class Details extends App.View

  /** @override */
  _tagName: \div

  /** @override */
  _className: "#{gz.Css \col-md-12} #{gz.Css \no-padding}"


  format-money: -> (new String(it)).replace /(\d)(?=(\d{3})+\.)/g, "$1, "

  _toJSON: -> do
    'details': @details
    'total': @sales
    'igv': @discount-igv
    'to_pay': @to-pay

  calculate-total: ->
    @sales = _.'reduce' ([parseFloat ..'amount' for @details]), (n, ax) -> n + ax

    @discount-igv = @sales * @igv
    @to-pay = @sales + @discount-igv

    @el._last.html = ''

    div-sales = App.dom._new \div
      .._class = "#{gz.Css \col-md-4} #{gz.Css \text-center}"
      ..html = "<strong>TOTAL VALOR VENTA</strong><br/>
                #{@type-currency._value} #{@sales.to-fixed 2}"
      @el._last._append ..

    div-amount-igv = App.dom._new \div
      .._class = "#{gz.Css \col-md-4} #{gz.Css \text-center}"
      ..html = "<strong>I.G.V (18%)</strong><br/>
                #{@type-currency._value} #{@discount-igv.to-fixed 2}"
      @el._last._append ..

    div-amount-to-pay = App.dom._new \div
      .._class = "#{gz.Css \col-md-4} #{gz.Css \text-center}"
      ..html = "<strong>TOTAL A PAGAR</strong><br/>
                #{@type-currency._value} #{@to-pay.to-fixed 2}"
      @el._last._append ..

  clean-elements: ->
    tquantity = @el.query ".#{gz.Css \quantity}"
    tunit = @el.query ".#{gz.Css \unit}"
    tdescription = @el.query 'textarea'
    tprice = @el.query ".#{gz.Css \price}"

    tprice._value = ''
    tdescription._value = ''
    tunit._value = 'UND'

  load-table: (details) ->
    @details = details
    @table-details.set-rows new CollectionDetail @details

    @table-details._show!
    @calculate-total!

  add-elements: ~>
    tquantity = @el.query ".#{gz.Css \quantity}"
    tunit = @el.query ".#{gz.Css \unit}"
    tdescription = @el.query 'textarea'
    tprice = @el.query ".#{gz.Css \price}"
    @_select-acomext._selected-index = 0

    tdescription._value = (String tdescription._value).replace /\n/g, '<br/>'
    price = parseFloat tprice._value
    quantity = parseInt tquantity._value
    amount = price * quantity

    if not tdescription._value or not quantity
      @clean-elements!
      return

    element =
      'quantity': quantity
      'price': price
      'description': tdescription._value
      'unit': tunit._value
      'amount': amount

    @details._push element

    @load-table @details
    # CLEAN
    @clean-elements!

  /** @override */
  initialize: ->
    @details = new Array
    super!

  /** @override */
  render: ->
    @el.html = "<div class='#{gz.Css \col-md-12} #{gz.Css \no-padding}
                          \ #{gz.Css \form-inline}'>
                <label>Tipo de Moneda : </label>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \billing-quantity}'>
                  <label>Cantidad</label>
                  <input type='number'
                         class='#{gz.Css \form-control}
                              \ #{gz.Css \quantity}'
                         min='1'
                         value='1' maxlength='2'/>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \billing-unit}'>
                  <label>Unidad</label>
                  <input type='text'
                         value='UND'
                         class='#{gz.Css \form-control}
                              \ #{gz.Css \unit}'/>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \billing-description}'>
                  <label>Descripcion</label>
                  <textarea class='#{gz.Css \form-control}
                                 \ #{gz.Css \description}'
                            rows='9'
                            cols='90'>
                  </textarea>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \billing-price}'>
                  <label>Precio</label>
                  <input type='text'
                         class='#{gz.Css \form-control}
                              \ #{gz.Css \price}'/>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \billing-plus}'>
                </div>"

    # TIPO DE MONEDA
    @type-currency = App.dom._new \select
      .._class = gz.Css \form-control
      .._name = 'billing_type'
      ..css = 'margin: 0 10 0 10'
      ..html = '<option>S/.</option>
                <option>USD</option>'
      ..on-change ~> @exchange-rate._class._toggle gz.Css \hidden
      @el._first._append ..

    # TIPO DE CAMBIO
    @exchange-rate = App.dom._new \span
      .._class = gz.Css \hidden
      ..html = "<label>Tipo de Cambio : </label>
                <input class='#{gz.Css \form-control}' type='text'
                       name='exchange_rate' style='margin-left: 10px' />"
      @el._first._append ..

    # ES DETRACCION?
    $ @el._first ._append "<span style='margin-left:15px'>
                            <label> Detracción: </label>
                            <div style='margin-left:15px'
                                 class='#{gz.Css \radio-inline}'>
                              <label>
                                <input type='radio' name='is_service'
                                       value='true' checked>
                                Si
                              </label>
                            </div>
                            <div class='#{gz.Css \radio-inline}'>
                              <label>
                                <input type='radio' name='is_service'
                                       value='false'>
                                No
                              </label>
                            </div>
                            </span>"
    # ACOMEXT U OTRO
    span-type = App.dom._new \span
      .._class = gz.Css \pull-right
      ..html = '<label>Opcion: </label>'
      @el._first._append ..

    @_select-acomext = App.dom._new \select
      .._class = gz.Css \form-control
      ..css = 'margin: 0 10 0 10'
      ..html = '<option>OTRO</option>
                <option>ACOMEXT</option>'
      ..on-change (evt) ~>
        if evt._target._value is \ACOMEXT
          (@el.query 'textarea')._value = ACOMEXT-DETAILS
        else
          (@el.query 'textarea')._value = ''
      span-type._append ..


    btn-plus = App.dom._new \button
      .._type = 'button'
      ..html = ' + '
      .._class = "#{gz.Css \btn} #{gz.Css \btn-default}"
      ..on-click @add-elements

    @el._last._append btn-plus

    _labels =
      'CANT.'
      'UNID.'
      'DESCRIPCION'
      'P. UNIT'
      'VALOR VENTA'
      ''

    _attributes =
      'quantity'
      'unit'
      'description'
      'price'
      'amount'
      'remove'

    _templates =
      'remove': (_value, _dto, _attr, _tr) ~>
        _span = App.dom._new \span
          .._class = "#{gz.Css \glyphicon}
                    \ #{gz.Css \glyphicon-remove}"
          ..css = 'cursor:pointer;font-size:18px'
          ..on-click ~>
            @details = @details.filter (el) -> el.'description' isnt _dto.'description'
            $ _tr ._remove!
            if @details._length is 0
              @table-details._hide!
              @el._last.html = ''
            else
              @calculate-total!

      'price': ~> "#{@type-currency._value} #{@format-money it.to-fixed 2}"

      'amount': ~> "#{@type-currency._value} #{@format-money it.to-fixed 2}"

    _column-cell-style =
        'description': 'width:350px;text-align:left'

    @table-details = new Table do
                      _labels: _labels
                      _attributes: _attributes
                      _templates: _templates
                      _column-cell-style: _column-cell-style

    @table-details.el._class = "#{gz.Css \table}
                              \ #{gz.Css \table-bordered}
                              \ #{gz.Css \hidden}"

    @el._append @table-details.render!.el

    App.dom._new \div
      .._class = "#{gz.Css \col-md-12} #{gz.Css \no-padding}"
      @el._append ..

    super!

  ACOMEXT-DETAILS = 'ACOMEXT - Asesor de Comercio Exterior\n
                     Tecnologia Web Services\n
                     Solución Smart Client\n
                     Incluye Licencia\n
                     Cotizacion 15-028 Renovacion Anual\n
                     Periodo de Actualizacion 12 meses calendario\n
                     Vigencia 01/06/2015 a 31/05/2016'

  /** @private */ igv: 0.18
  /** @private */ details: null
  /** @private */ table-details: null
  /** @private */ sales: null
  /** @private */ type-currency: null
  /** @private */ exchange-rate: null
  /** @private */ discount-igv: null
  /** @private */ to-pay: null
  /** @private */ _select-acomext: null

/** @export */
module.exports = Details


# vim: ts=2:sw=2:sts=2:et
