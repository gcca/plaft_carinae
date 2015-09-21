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
    'is_service': @sales > 750

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


  add-elements: ~>
    inputs = @el.queryAll 'input'
    tquantity = inputs.'1'
    tunit = inputs.'2'
    tdescription = @el.query 'textarea'
    tprice = inputs.'3'

    price = parseFloat tprice._value
    quantity = parseInt tquantity._value
    amount = price * quantity

    if not tdescription._value or not price or not quantity
      tquantity._value = '1'
      tprice._value = ''
      tdescription._value = ''
      tunit._value = ''
      return

    element =
      'quantity': quantity
      'price': price
      'description': tdescription._value
      'unit': tunit._value
      'amount': amount

    @details._push element

    @table-details.set-rows new CollectionDetail @details
    # CLEAN
    tquantity._value = '1'
    tprice._value = ''
    tdescription._value = ''
    tunit._value = 'UND'

    @table-details._show!
    @calculate-total!

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
                         class='#{gz.Css \form-control}'
                         min='1'
                         value='1' maxlength='2'/>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \billing-unit}'>
                  <label>Unidad</label>
                  <input type='text'
                         value='UND'
                         class='#{gz.Css \form-control}'/>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \billing-description}'>
                  <label>Descripcion</label>
                  <textarea class='#{gz.Css \form-control}'
                            rows='4'
                            cols='90'>
                  </textarea>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \billing-price}'>
                  <label>Precio</label>
                  <input type='text'
                         class='#{gz.Css \form-control}'/>
                </div>
                <div class='#{gz.Css \form-group}
                          \ #{gz.Css \billing-plus}'>
                </div>"

    @type-currency = App.dom._new \select
      .._class = gz.Css \form-control
      .._name = 'billing_type'
      ..css = 'margin: 0 10 0 10'
      ..html = '<option>S/.</option>
                <option>USD</option>'
      ..on-change ~> @exchange-rate._class._toggle gz.Css \hidden
      @el._first._append ..

    @exchange-rate = App.dom._new \span
      .._class = gz.Css \hidden
      ..html = '<label>Tipo de Cambio : </label>'

    App.dom._new \input
      .._class = gz.Css \form-control
      ..css = 'margin-left: 10px'
      .._name = 'exchange_rate'
      .._type = 'text'
      @exchange-rate._append ..

    @el._first._append @exchange-rate

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
        'description': 'width:350px'

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


  /** @private */ igv: 0.18
  /** @private */ details: null
  /** @private */ table-details: null
  /** @private */ sales: null
  /** @private */ type-currency: null
  /** @private */ exchange-rate: null
  /** @private */ discount-igv: null
  /** @private */ to-pay: null

/** @export */
module.exports = Details


# vim: ts=2:sw=2:sts=2:et
