/** @module modules.log */

panelgroup = App.widget.panelgroup
GenericBody = require './generic'

class RegisterBody extends GenericBody

  /**
   * Crear despachos.
   */
  create-dispatches: (evt) ~>
    button = evt._target
    button._old-name = button.html
    quantity =  @el.query '[name=dispatch_quantity]'
    dto =
      'quantity': quantity._value
      'customs-agency': @customs-agency-id
    @load-events-button button, @kStatus.Loading

    App.ajax._post '/api/sampledata/create_dispatches', dto , do
      _success: (data) ~>
        tbl = ["<span>#{d.'order'} : #{d.'income_date'} - \
                #{d.'description'} </span><br/>" for d in data]
        @load-events-button button, @kStatus.Success
        @load-modal tbl.join ''
      _error: ~>
        @load-events-button button, @kStatus.Error

  /**
   * Crear despachos.
   */
  numerate-dispatches: (evt) ~>
    button = evt._target
    button._old-name = button.html
    percent =  @el.query '[name=numerate_percent]'
    dto =
      'percent': percent._value
      'customs-agency': @customs-agency-id

    @load-events-button button, @kStatus.Loading

    App.ajax._post '/api/sampledata/numerate_dispatches', dto , do
      _success: (data) ~>
        tbl = ["<span>#{d.'order'} : #{d.'dam'} - \
                #{d.'amount'} - #{d.'channel'} </span><br/>" for d in data]
        @load-events-button button, @kStatus.Success
        @load-modal tbl.join ''
      _error: ~>
        @load-events-button button, @kStatus.Error

  /**
   * Identificar operaciones
   */
  create-operations: (evt) ~>
    button = evt._target
    button._old-name = button.html
    dto =
      'customs-agency': @customs-agency-id

    @load-events-button button, @kStatus.Loading

    App.ajax._post '/api/sampledata/create_operation', dto , do
      _success: (operations) ~>
        tbl = ["<ul>#{["<li>#{..'order'} : \
                        #{..'dam'}  - \
                        #{..'numeration_date'}</li>" \
                        for o.'dispatches']._join ''} \
               </ul><br/>" for o in operations]
        @load-events-button button, @kStatus.Success
        @load-modal tbl.join ''
      _error: ~>
        @load-events-button button, @kStatus.Error



  /** @override */
  render: ->
    ret = super!

    ###########################################
    ## CREAR DESPACHOS
    ###########################################
    b-dispatch = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = "<label>Crear despachos: </label>
                <input type='text' name='dispatch_quantity'
                       class='#{gz.Css \form-control}' />"
      @body._append ..

    App.dom._new \button
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}
                \ #{gz.Css \btn-sm}"
      .._type = 'button'
      ..html = 'Generar nuevos Despachos'
      ..on-click  @create-dispatches
      b-dispatch._append ..

    ###########################################
    ## NUMERAR DESPACHOS
    ###########################################
    b-numerate = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = "<label>Numerar despachos: </label>
                <input type='text' name='numerate_percent'
                       placeholder='Porcentaje a generar'
                       class='#{gz.Css \form-control}' />"
      @body._append ..

    App.dom._new \button
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}
                \ #{gz.Css \btn-sm}"
      .._type = 'button'
      ..html = 'Numerar Despachos'
      ..on-click  @numerate-dispatches
      b-numerate._append ..

    ###########################################
    ## IDENTIFICAR OPERACIONES
    ###########################################
    b-operation = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = '<label>Identificar las operaciones </label>
                <small>- operaciones inusuales</small>'
      @body._append ..

    App.dom._new \button
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}
                \ #{gz.Css \btn-sm}"
      .._type = 'button'
      ..html = 'Identificar Operaciones'
      ..on-click  @create-operations
      b-operation._append ..


    ###########################################
    ## Utils
    ###########################################
    (@el.query '[name=numerate_percent]').on-blur (evt) ~>
      value = evt._target._value
      if value is '' or (parseFloat value) > 100 or (parseFloat value) < 0
        evt._target._value = ''

    ret

/** @export */
module.exports = RegisterBody


# vim: ts=2:sw=2:sts=2:et
