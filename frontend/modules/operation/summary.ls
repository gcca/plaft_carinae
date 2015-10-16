/** @module modules */

Module = require '../../workspace-new/module'


class Summary extends Module

  /** @override */
  _tagName: \form

  /**
   * (Event) Accept dispatch (to operation).
   * @private
   */
  on-accept: ~>
    App.ajax._post "/api/dispatch/#{@model._id}/accept_anexo", null, do
      _success: ~>
        alert 'ACEPTADO'
      _bad-request: ~>
        alert 'DENEGADO (Error)'

  empty-field: (value) ->
    if value? and value isnt ''
      value
    else
      App.dom._new \span
        ..css = 'color:red;font-size:22px'
        ..title = 'Valor no encontrado'
        ..html = '*'
        $ .. ._tooltip do
          'template': "<div class='#{gz.Css \tooltip}' role='tooltip'
                            style='min-width:175px'>
                         <div class='#{gz.Css \tooltip-arrow}'></div>
                         <div class='#{gz.Css \tooltip-inner}'></div>
                       </div>"

  make-header: (_dto) ->
    customer = _dto.'declaration'.'customer'
    _name = if customer.'document_type' is \ruc then customer.'name' \
            else "#{customer.'name'} #{customer.'father_name'}
                \ #{customer.'mother_name'}"

    $ @el._first ._append "
      <div class='#{gz.Css \col-md-4}'>
        <label class='#{gz.Css \col-md-4}'
               style='padding:0'>
          N&ordm; Orden
        </label>
        <label class='#{gz.Css \col-md-8}'
               style='border:solid'>
          #{@empty-field _dto.'order'}
        </label>
        <label class='#{gz.Css \col-md-4}'
               style='padding:0'>
          N&ordm; DAM
        </label>
        <label class='#{gz.Css \col-md-8}'
               style='border:solid'>
          #{@empty-field _dto.'dam', 'dam'}
        </label>
        <label class='#{gz.Css \col-md-4}'
               style='padding:0'>
          Tipo de operación
        </label>
        <label class='#{gz.Css \col-md-8}'
               style='border:solid'>
          #{_dto.'regime'.'name'}
        </label>
      </div>

      <div class='#{gz.Css \col-md-8}'>
        <label class='#{gz.Css \col-md-4}'>
          Razón social/Nombre
        </label>
        <label class='#{gz.Css \col-md-8}'
               style='border:solid'>
          #{_name}
        </label>
        <label class='#{gz.Css \col-md-4}'>
          Fecha numeración
        </label>
        <label class='#{gz.Css \col-md-8}'
               style='border:solid'>
          #{@empty-field _dto.'numeration_date', 'numeration_date'}
        </label>
        <label class='#{gz.Css \col-md-4}'>
          Descripción
        </label>
        <label class='#{gz.Css \col-md-8}'
               style='border:solid'>
          #{@empty-field _dto.'regime'.'name'}
        </label>
      </div>"


  make-table: (_attributes, _dto) ->
    _table = App.dom._new \table
      .._class = "#{gz.Css \table}
                \ #{gz.Css \table-bordered}"
    t-body = App.dom._new \tbody
    for attr in _attributes
      row = App.dom._new \tr

      if attr[0] isnt ''
        App.dom._new \td
          ..css = 'width: 0.5%'
          ..html = attr[0]
          row._append ..

        App.dom._new \td
          .._class = gz.Css \col-md-7
          ..html = attr[1]
          row._append ..

        App.dom._new \td
          .._class = gz.Css \col-md-5
          $ .. ._append @empty-field attr[2] _dto
          row._append ..

        t-body._append row

    _table._append t-body
    _table


  /** @override */
  render: ->
    @el.html = "
    <div class='#{gz.Css \col-md-11}' style='padding:0'>
    </div>
    <div class='#{gz.Css \col-md-1}' style='padding:0'>
      <div class='#{gz.Css \col-md-12}
                \ #{gz.Css \col-sm-6}'
           style='padding:0'>
        <button type='button'
                class='#{gz.Css \btn}
                     \ #{gz.Css \btn-success'}'>
          Aceptar
        </button>
      </div>
    </div>
    <div class='#{gz.Css \col-md-12}'>
    </div>"

    btn-accept = @el.query ".#{gz.Css \btn-success}"

    btn-accept.on-click @on-accept

    dispatch = @model._attributes
    App.lists.operation
      third = ..third._template
      declarant = ..declarant._template
      operation = ..operation._template
      customer = ..customer._template
      stakeholder = ..stakeholder._template
      customer-function = ..customer._method
      stakeholder-function = ..stakeholder._method

    @make-header dispatch

    # DECLARANTE
    for dcl in dispatch.'declaration'.'customer'.'declarants'
      @$el._append "<h4 class='#{gz.Css \col-md-12}'> DATOS DE IDENTIFICACIÓN
                   \ DE LAS PERSONASQUE SOLICITA O FISICAMENTE REALIZA
                   \ LA OPERACIÓN EN REPRESENTACIÓN DEL CLIENTE DEL SUJETO
                   \ OBLIGADO (DECLARANTE).'</h4>"
      @el._append @make-table declarant, dcl

    customer-dto = dispatch.declaration.customer
    stakeholder-dto = dispatch.stakeholders[0]

    if not dispatch.'is_out'
      customers = []
      stakeholders = []
      for [c, s] in _.zip customer, stakeholder-function
        customers._push [c[0], c[1], s]
      for [x, y] in _.zip stakeholder, customer-function
        stakeholders._push [x[0], x[1], y]
      customer = customers
      stakeholder = stakeholders
      customer-dto = dispatch.stakeholders[0]
      stakeholder-dto = dispatch.declaration.customer

    @$el._append '<h4>DATOS DE IDENTIFICACIÓN DE LAS PERSONAS
                        \ EN CUYOS NOMBRES SE REALIZA LA OPERACIÓN
                        \ ORDENANTES/PROVEEDOR EXTRANJERO (INGRESO DE
                        \ MERCANCÍA)/ EXPORTADOR(SALIDA DE MERCANCÍA)</h4>'
    @el._append @make-table customer, customer-dto

    @$el._append '<h4>DATOS DE IDENTIFICACIÓN DE LAS PERSONAS A FAVOR
                        \ DE QUIENES SE REALIZA LA OPERACIÓN: IMPORTADOR
                        \ (INGRESO DE MERCANCÍA)/DESTINATARIO DEL EMBARQUE
                        \ (SALIDA DE MERCANCÍA)</h4>'

    stakeholder._slice 1, 1
    @el._append @make-table stakeholder, stakeholder-dto

    third-dto = dispatch.'declaration'.'third'
    if not third-dto?
      third-dto = new Object

    # THIRD
    @$el._append '<h4>DATOS DE IDENTIFICACIÓN DEL TERCERO POR
                        \ CUYO INTERMEDIO SE REALIZA LA OPERACIÓN, DE
                        \ SER EL CASO.</h4>'
    @el._append @make-table third, third-dto

    #OPERATION
    @$el._append '<h4>DATOS RELACIONADOS A LA DESCRIPCIÓN DE LA
                        \ OPERACIÓN</h4>'
    @el._append @make-table operation, dispatch


    super!


/** @export */
module.exports = Summary


# vim: ts=2:sw=2:sts=2:et
