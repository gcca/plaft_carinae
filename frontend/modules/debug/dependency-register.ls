/** @module modules.log */

panelgroup = App.widget.panelgroup
GenericBody = require './generic'

class RegisterBody extends GenericBody

  /**
   * Crear despachos.
   */
  create-dispatches: (evt) ~>
    button = evt._target
    quantity =  @el.query '[name=dispatch_quantity]'
    dto =
      'quantity': quantity._value
      'customs-agency': @customs-agency-id
    @load-events-button button, @kStatus.Loading

    App.ajax._post '/api/sampledata/create_dispatches', dto , do
      _success: (data) ~>
        tbl = ["<span>#{d.'order'} : #{d.'income_date'} - \
                #{d.'description'} </span><br/>" for d in data]
        @load-events-button button, @kStatus.Success, 'Se creo los despachos'
        @load-modal tbl.join ''
      _error: ~>
        @load-events-button button, @kStatus.Error, 'Error al crear'

  /**
   * Numerar despachos.
   */
  numerate-dispatches: (evt) ~>
    button = evt._target
    percent =  @el.query '[name=numerate_percent]'
    dto =
      'percent': percent._value
      'customs-agency': @customs-agency-id

    @load-events-button button, @kStatus.Loading

    App.ajax._post '/api/sampledata/numerate_dispatches', dto , do
      _success: (data) ~>
        tbl = ["<span>#{d.'order'} : #{d.'dam'} - \
                #{d.'amount'} - #{d.'channel'} </span><br/>" for d in data]
        @load-events-button button, @kStatus.Success, 'Se enumero los despachos'
        @load-modal tbl.join ''
      _error: ~>
        @load-events-button button, @kStatus.Error, 'Error al enumerar'

  /**
   * Identificar operaciones
   */
  create-operations: (evt) ~>
    button = evt._target
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
        @load-events-button button, @kStatus.Success, 'Operaciones Creadas'
        @load-modal tbl.join ''
      _error: ~>
        @load-events-button button, @kStatus.Error, 'Error al crear'

  /**
   * Identificar operaciones
   */
  create-employees: (evt) ~>
    button = evt._target
    quantity =  @el.query '[name=employee_quantity]'
    dto =
      'customs-agency': @customs-agency-id
      'quantity': quantity._value

    @load-events-button button, @kStatus.Loading

    App.ajax._post '/api/sampledata/create_employees', dto , do
      _success: (employees) ~>
        tbl = ["#{e.'name'} (#{e.'username'}) - e.'role'} <br/>" \
               for e in employees]
        @load-events-button button, @kStatus.Success, 'Empleados registrados'
        @load-modal tbl.join ''
      _error: ~>
        @load-events-button button, @kStatus.Error, 'Error al registrar'


  /**
   * Operaciones inusuales.
   */
  create-unusual: (evt) ~>
    button = evt._target
    percent =  @el.query '[name=unusual_percent]'
    dto =
      'percent': percent._value
      'customs-agency': @customs-agency-id

    @load-events-button button, @kStatus.Loading

    App.ajax._post '/api/sampledata/create_unusual', dto , do
      _success: (data) ~>
        @load-events-button button, @kStatus.Success, 'Se creo las operaciones'
      _error: ~>
        @load-events-button button, @kStatus.Error, 'Error al crear'

  /** @override */
  render: ->
    ret = super!

    ###########################################
    ## CREAR EMPLEADOS
    ###########################################
    b-employee = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = "<label>Crear Empleados: </label>
                <input type='text' name='employee_quantity'
                       class='#{gz.Css \form-control}' />"
      @body._append ..

    App.dom._new \button
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}
                \ #{gz.Css \btn-sm}"
      .._type = 'button'
      ..html = 'Ejecutar'
      ..on-click  @create-employees
      b-employee._append ..

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
      ..html = 'Ejecutar'
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
      ..html = 'Ejecutar'
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
      ..html = 'Ejecutar'
      ..on-click  @create-operations
      b-operation._append ..

    ###########################################
    ## CALCULAR INUSUALES
    ###########################################
    b-unusual = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = "<label>Operaciones Inusuales: </label>
                <input type='text' name='unusual_percent'
                       placeholder='Porcentaje a generar'
                       class='#{gz.Css \form-control}' />"
      @body._append ..

    App.dom._new \button
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}
                \ #{gz.Css \btn-sm}"
      .._type = 'button'
      ..html = 'Ejecutar'
      ..on-click  @create-unusual
      b-unusual._append ..


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
