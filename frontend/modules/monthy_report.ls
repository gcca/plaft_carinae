/** @module modules */

Module = require '../workspace/module'

class ReportEdit extends Module

  /** @override */
  _tagName: \form

  calculate-field: (n1, n2) ->
    result = parseFloat n1*n2
    result.to-fixed 2

  upper-field: (_value, _field='-') ->
    if _value?
      @empty-field _value.to-upper-case!, _field
    else
      @empty-field _value, _field

  no-important: (_value) ->
    if _value?
      if _value is ''
        return '<span>No aplica</span>'
      else
        return  _value
    else
      return '<span>No aplica</span>'

  empty-field: (value, _field) ->
    if _field?
      _title = 'Campo no ingresado por favor verifique en el módulo de
               \ numeración.'
    else
      _title = "Campo no ingresado por favor verifique en el módulo de
               \ operación. #{@_tip-module}"

    _span = App.dom._new \span
      ..css = 'color:red;font-size:22px'
      ..title = _title
      ..html = '*'
      $ .. ._tooltip do
        'template': "<div class='#{gz.Css \tooltip}' role='tooltip'
                          style='min-width:175px'>
                       <div class='#{gz.Css \tooltip-arrow}'></div>
                       <div class='#{gz.Css \tooltip-inner}'></div>
                     </div>"
    if value?
      if value is ""
        return _span
      else
        return value
    else
      return _span

  in-country: (_value, _field='-') ->
    if @_type
      return @empty-field _value, _field
    else
      return '<span>No aplica</span>'

  out-country: (_value, _field='-') ->
    if not @_type
      return @empty-field _value, _field
    else
      return '<span>No aplica</span>'

  load-header: (_dto) ->
    _customer = _dto.'declaration'.'customer'
    if _customer.'document_type' is \ruc
      _name = _customer.'name'
    else
      _name = "#{_customer.'name'}
             \ #{_customer.'father_name'}
             \ #{_customer.'mother_name'}"
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
          #{@check-code-sbs _dto.'regime'.'name'}
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


  load-list-operation: (_dto) ->
    _customer = _dto.'declaration'.'customer'
    _stk = _dto.'stakeholders'.'0'
    _code-sbs = @check-code-sbs _dto.'regime'.'name'

    _list-operation = []
    @_tip-module = 'Ver en ANEXO 5.'
    _list-operation._push @empty-field _customer.'money_source_type'
    _list-operation._push _dto.'regime'.'name' + "("+_code-sbs+")"
    _list-operation._push '<span>No aplica</span>'
    @_tip-module = 'Ver en Nº Orden despacho.'
    _list-operation._push @empty-field _dto.'description'
    _list-operation._push @empty-field _dto.'dam', 'dam'
    _list-operation._push @empty-field _dto.'numeration_date', 'numeration_date'
    @_tip-module = 'Ver en ANEXO 5.'
    _list-operation._push @empty-field _customer.'money_source'
    _list-operation._push 'USD'
    _list-operation._push '<span>No aplica</span>'
    _list-operation._push @calculate-field _dto.'amount', _dto.'exchange_rate'
    _list-operation._push @empty-field _dto.'exchange_rate', 'exchange_rate'
    @_tip-module = 'Ver en Vinculados.'
    _list-operation._push @in-country _stk.'country'  # Verificar de donde sacar el dato.
    _list-operation._push @out-country _stk.'country'  # Verificar de donde sacar el dato.


    @load-table App.lists.anexo2.operation._code,
                App.lists.anexo2.operation._display,
                _list-operation

  load-list-third: (_third) ->  # HARDCODE
    @_tip-module = 'Ver Tercero.'
    list-third = []
    if _third?
      if _third.'document_type'?
        if _third.'document_type' is \ruc
          _third-type = 'Persona Jurídica'
          _third-name = _third.'name'
          _name69 = '<span>No aplica</span>'
          _dtype = '<span>No aplica</span>'
        else
          _third-type = 'Persona Natural'
          _third-name = _third.'father_name'
          _name69 = _third.'name'
          _dtype = _third.'document_type'

        list-third._push @empty-field _third-type
        list-third._push @upper-field _dtype
        list-third._push @empty-field _third.'document_number'
        list-third._push @empty-field _third-name
        list-third._push @empty-field _third.'mother_name'
        list-third._push @empty-field _name69
        list-third._push @empty-field _third.'third_ok'
      else
        list-third = ['<span>No aplica</span>' for til 7]
    else
      list-third = ['<span>No aplica</span>' for til 7]

    @load-table App.lists.anexo2.third._code,
                App.lists.anexo2.third._display,
                list-third

  load-list-declarant: (_dto) ->
    @_tip-module = 'Ver en declarante.'
    _declarant = _dto.'0'
    if not _declarant?
      list-declarant = ['-' for til 16]

      @load-table App.lists.anexo2.declarant._code,
                  App.lists.anexo2.declarant._display,
                  list-declarant
      return
    list-declarant = []


    if _declarant.'ciiu'?
      _ciiu = _declarant.'ciiu'.'name'

    if _declarant.'ubigeo'?
      _ubigeo = _declarant.'ubigeo'.'code' + " " + _declarant.'ubigeo'.'name'

    list-declarant._push @empty-field _declarant.'represents_to'
    list-declarant._push @empty-field _declarant.'residence_status'
    list-declarant._push @upper-field _declarant.'document_type'
    list-declarant._push @empty-field _declarant.'document_number'
    list-declarant._push @empty-field _declarant.'issuance_country'
    list-declarant._push @empty-field _declarant.'father_name'
    list-declarant._push @empty-field _declarant.'mother_name'
    list-declarant._push @empty-field _declarant.'name'
    list-declarant._push @empty-field _declarant.'nationality'
    list-declarant._push @empty-field _declarant.'activity'
    list-declarant._push '<span>No aplica</span>'
    list-declarant._push @empty-field _ciiu
    list-declarant._push @no-important _declarant.'position'
    list-declarant._push @empty-field _declarant.'address'
    list-declarant._push @empty-field _ubigeo
    list-declarant._push @empty-field _declarant.'phone'

    @load-table App.lists.anexo2.declarant._code,
                App.lists.anexo2.declarant._display,
                list-declarant

  load-list-customer: (_dto, _title, _isTrue=on) ->
    @_tip-module = 'Ver en ANEXO 5'
    list-customer = []
    _customer = _dto.'declaration'.'customer'
    if _customer.'document_type' is \ruc
      _customer-type = 'Persona Jurídica'
      _dnumber = '<span>No aplica </span>'
      _document-number = _customer.'document_number'
      _document-type = '<span>No aplica </span>'
      _name = _customer.'name'
      _name35 = '<span>No aplica </span>'
      _ocupation = '<span>No aplica </span>'
      _activity = _customer.'activity'
      _mother-name = '<span>No aplica </span>'
      _customer.'issuance_country' = '<span>No aplica </span>'
      _customer.'nationality' = '<span>No aplica </span>'
    else
      _customer-type = 'Persona Natural'
      _dnumber = _customer.'document_number'
      _document-number = _customer.'ruc'
      _name = _customer.'father_name'
      _name35 = _customer.'name'
      _ocupation = _customer.'activity'
      _activity = '<span>No aplica </span>'
      _document-type = _customer.'document_type'
      _mother-name = _customer.'mother_name'

    list-customer._push _title
    if _isTrue
      _code-array = App.lists.anexo2.linked1._code
      _display-array = App.lists.anexo2.linked1._display
      list-customer._push  @empty-field _customer.'legal_type'
    else
      _code-array = App.lists.anexo2.linked2._code
      _display-array = App.lists.anexo2.linked2._display

    if _customer.'ciiu'?
      _ciiu = _customer.'ciiu'.'name'

    if _customer.'ubigeo'?
      _ubigeo = _customer.'ubigeo'.'code' + " " + _customer.'ubigeo'.'name'

    list-customer._push  @empty-field _customer.'condition'
    list-customer._push  @empty-field _customer-type
    list-customer._push  @empty-field _document-type
    list-customer._push  @empty-field _dnumber
    list-customer._push  @empty-field _customer.'issuance_country'
    list-customer._push  @empty-field _document-number
    list-customer._push  @empty-field _name
    list-customer._push  @empty-field _mother-name
    list-customer._push  @empty-field _name35
    list-customer._push  @empty-field _customer.'nationality'
    list-customer._push  @empty-field _ocupation
    list-customer._push  '<span>No aplica</span>' # Ya no existe descripcion de otros
    list-customer._push  @empty-field _activity
    list-customer._push  @empty-field _ciiu
    list-customer._push  @no-important _customer.'employment'
    list-customer._push  @empty-field _customer.'fiscal_address'
    list-customer._push  @empty-field _ubigeo
    list-customer._push  @empty-field _customer.'phone'

    @load-table _code-array,
                _display-array,
                list-customer

  load-list-stakeholder: (_stakeholders, _isTrue=on) ->
    @_tip-module = 'Ver en Vinculados.'
    for _stkholder in _stakeholders
      list-linked = []

      # Verificar stakeholder
      if _stkholder.'document_type' is \ruc
        _stkholder-type = 'Persona Jurídica'
        _name = _stkholder.'name'
        _name35 = '<span>No aplica</span>'
        _mother-name = '<span>No aplica </span>'
      else
        _stkholder-type = 'Persona Natural'
        _name = _stkholder.'father_name'
        _name35 = _stkholder.'name' # Nombre de persona Natural
        _mother-name = _stkholder.'mother_name'

      list-linked._push  @empty-field _stkholder.'link_type'
      if _isTrue
        _code-array = App.lists.anexo2.linked1._code
        _display-array = App.lists.anexo2.linked1._display
        list-linked._push  @no-important _stkholder.'legal_type'
      else
        _code-array = App.lists.anexo2.linked2._code
        _display-array = App.lists.anexo2.linked2._display

      list-linked._push  @no-important _stkholder.'condition'
      list-linked._push  _stkholder-type  # Verificar tipo de persona
      list-linked._push  '<span>No aplica</span>'
      list-linked._push  '<span>No aplica</span>'
      list-linked._push  '<span>No aplica</span>'
      list-linked._push  '<span>No aplica</span>'
      list-linked._push  @empty-field _name
      list-linked._push  @empty-field _mother-name
      list-linked._push  @empty-field _name35
      list-linked._push  '<span>No aplica</span>'
      list-linked._push  '<span>No aplica</span>'
      list-linked._push  '<span>No aplica</span>'
      list-linked._push  '<span>No aplica</span>'
      list-linked._push  '<span>No aplica</span>'
      list-linked._push  '<span>No aplica</span>'
      list-linked._push  @empty-field _stkholder.'address'
      list-linked._push  '<span>No aplica</span>'
      list-linked._push  '<span>No aplica</span>'

      @load-table _code-array,
                  _display-array,
                  list-linked

  load-table: (list1, list2, list3) ->
    _table = App.dom._new \table
      .._class = "#{gz.Css \table}
                \ #{gz.Css \table-bordered}"
    _tbody = App.dom._new \tbody
    for [f, s, m] in _.zip list1, list2, list3
      _tr = App.dom._new \tr
      App.dom._new \td
        ..css = 'width: 0.5%'
        ..html = f
        _tr._append ..
      App.dom._new \td
        .._class = gz.Css \col-md-7
        ..html = s
        _tr._append ..
      App.dom._new \td
        .._class = gz.Css \col-md-5
        if typeof m is 'string'
          ..html = m
        else
          .._append m
        _tr._append ..
      _tbody._append _tr
    _table._append _tbody
    @el._last._append _table

  check-commodity: (_name-regime) ->
    _k = App.lists.regime._display._index _name-regime

    return App.lists.regime._sbs[_k]

  check-code-sbs: (_name-regime) ->
    _k = App.lists.regime._display._index _name-regime

    return App.lists.regime._sbs-code[_k]


  /** @override */
  render: ->
    @el.html = "
    <div class='#{gz.Css \col-md-11}' style='padding:0'>
    </div>
    <div class='#{gz.Css \col-md-12}'>
    </div>"


    _dto-anexo2 = @model._attributes


    @load-header _dto-anexo2

    $ @el._last ._append '<h4>DATOS DE IDENTIFICACIÓN DE LAS PERSONAS
                          \ QUE SOLICITA O FISICAMENTE REALIZA LA OPERACIÓN
                          \ EN REPRESENTACIÓN DEL CLIENTE DEL SUJETO OBLIGADO
                          (DECLARANTE).</h4>'

    @load-list-declarant _dto-anexo2.'declaration'.'customer'.'declarants'

    @_type = @check-commodity _dto-anexo2.'regime'.'name'
    if @_type

      $ @el._last ._append '<h4>DATOS DE IDENTIFICACIÓN DE LAS PERSONAS
                          \ EN CUYOS NOMBRES SE REALIZA LA OPERACIÓN
                          \ ORDENANTES/PROVEEDOR EXTRANJERO (INGRESO DE
                          \ MERCANCÍA)/ EXPORTADOR(SALIDA DE MERCANCÍA)</h4>'

      @load-list-stakeholder _dto-anexo2.'stakeholders'

      $ @el._last ._append '<h4>DATOS DE IDENTIFICACIÓN DE LAS PERSONAS A FAVOR
                          \ DE QUIENES SE REALIZA LA OPERACIÓN: IMPORTADOR
                          \ (INGRESO DE MERCANCÍA)/DESTINATARIO DEL EMBARQUE
                          \ (SALIDA DE MERCANCÍA)</h4>'

      @load-list-customer _dto-anexo2, 'Importador', off


    else

      $ @el._last ._append '<h4>DATOS DE IDENTIFICACIÓN DE LAS PERSONAS
                          \ EN CUYOS NOMBRES SE REALIZA LA OPERACIÓN
                          \ ORDENANTES/PROVEEDOR EXTRANJERO (INGRESO DE
                          \ MERCANCÍA)/ EXPORTADOR(SALIDA DE MERCANCÍA)</h4>'

      @load-list-customer _dto-anexo2, 'Exportador'

      $ @el._last ._append '<h4>DATOS DE IDENTIFICACIÓN DE LAS PERSONAS A FAVOR
                          \ DE QUIENES SE REALIZA LA OPERACIÓN: IMPORTADOR
                          \ (INGRESO DE MERCANCÍA)/DESTINATARIO DEL EMBARQUE
                          \ (SALIDA DE MERCANCÍA)</h4>'

      @load-list-stakeholder _dto-anexo2.'stakeholders', off


    $ @el._last ._append '<h4>DATOS DE IDENTIFICACIÓN DEL TERCERO POR
                        \ CUYO INTERMEDIO SE REALIZA LA OPERACIÓN, DE
                        \ SER EL CASO.</h4>'

    @load-list-third _dto-anexo2.'declaration'.'third'

    $ @el._last ._append '<h4>DATOS RELACIONADOS A LA DESCRIPCIÓN DE LA
                        \ OPERACIÓN</h4>'
    @load-list-operation _dto-anexo2

    super!

  /** @private */ _type: null
  /** @private */ _tip-module: null

/**
* @class Dispatch
* @extends Model
*/
class Dispatch extends App.Model
  urlRoot: 'dispatch'


/**
 * Welcome
 * -------
 * Welcome page for dashboard.
 * @class Welcome
 * @extends Module
 */
class MonthyReport extends Module

  add-head: ->
    _tr = App.dom._new \tr
    for k in &
      _td = App.dom._new \td
      @create-td _td, k
      _td.css\font-weight = \bold
      _tr._append _td
    _thead = App.dom._new \thead
    _thead._append _tr
    @_table._append _thead

  create-td: (_td, value) ->
    if value.__proto__.constructor is Array
      if value[2]?
        $(_td).attr value[2]
      if value[1]?
        _td.css = value[1]
      _td.html = value[0]
    else
      _td.html = value

  add-row: ->
    _tr = App.dom._new \tr
    _model = &.0
    delete &.0
    for k in &
      if k isnt undefined
        _td = App.dom._new \td
        @create-td _td, k
        _tr.on-dbl-click ~>
          @_desktop.load-next-page ReportEdit, do
                              model: _model
        _tr._append _td
    @_tbody._append _tr

  add-table: (operations) ->
      @_table = App.dom._new \table
        .._class = "#{gz.Css \table} #{gz.Css \table-hover}"
      @_tbody = App.dom._new \tbody

      @add-head 'No Orden', 'Rg.', 'No Fila' ,'No Registro',
                ['DAM', 'text-align:center;', {colspan:'2'}],
                'Md. Op.', 'N. Md.', 'FOB', 'Fecha Num.'
      for operation in operations
        for [dispatch, i] in _.zip operation.'dispatches', operation.'num_modalidad'
          amount = (parseFloat dispatch.'amount').to-fixed 2
          change = parseFloat dispatch.'exchange_rate'
          @add-row (new Dispatch dispatch),
                   dispatch.'order',
                   dispatch.'regime'.'code',
                   operation.'row_number',
                   operation.'register_number',
                   [dispatch.'dam', 'text-align:center;', {colspan:'2'}],
                   operation.'modalidad',
                   i,
                   "#{if amount >10000 then "<span style='color:red'>#{amount}</span>" else amount }",
                   dispatch.'numeration_date'

      @_table._append @_tbody
      @el._append @_table

  /** @override */
  render: ->
    @clean!
    @_desktop._lock!
    @_desktop._spinner-start!
    @$el._append "<a class='#{gz.Css \btn}
                              \ #{gz.Css \btn-primary}
                              \ #{gz.Css \pull-right}'
                    href='/api/operation/monthly_report'>
                 Generar Reporte
                 </a>"
    App.ajax._get '/api/operation/operations', true, do
      _success: (_dto) ~>
        @add-table _dto
        @_desktop._unlock!
        @_desktop._spinner-stop!
    super!

  _table: null
  _tbody: null
  /** @protected */ @@_caption = 'RO - PROCESO MENSUAL'
  /** @protected */ @@_icon    = gz.Css \certificate
  /** @protected */ @@_hash    = 'OPLIST-HASH'


/** @export */
module.exports = MonthyReport


# vim: ts=2:sw=2:sts=2:et
