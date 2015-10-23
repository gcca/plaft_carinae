/** @module modules.debug */

GenericBody = require './generic'

class NoDependency extends GenericBody

  /**
   * Crear agencia de aduanas.
   */
  create-agency: (evt) ~>
    button = evt._target
    @load-events-button button, @kStatus.Loading
    App.ajax._post '/api/sampledata/create_agency', null, do
      _success: (data) ~>
        mensaje = "<span>Agencia creada: <br/>
                   Nombre de agencia: #{data.'name'}<br/>
                   Oficial : #{data.'officer'.'name'}<br/>
                   Usuario : #{data.'officer'.'username'}
                   </span>"
        @load-events-button button, @kStatus.Success, 'Agencia creada'
        @load-modal mensaje
      _error: ~>
        @load-events-button button, @kStatus.Error, 'Error al crear agencia'

  /**
   * Crear clientes.
   */
  create-customers: (evt) ~>
    button = evt._target
    @load-events-button button, @kStatus.Loading
    App.ajax._post '/api/sampledata/create_customers', null, do
      _success: (data) ~>
        tbl = ["<span>#{d.'document_number'} : (#{d.'document_type'}) - \
                #{d.'name'} </span><br/>" for d in data]
        @load-events-button button, @kStatus.Success, 'Clientes creados.'
        @load-modal tbl.join ''
      _error: ~>
        @load-events-button button, @kStatus.Error, 'Error al crear clientes.'

  /**
   * Crear stakeholders.
   */
  create-stakeholders: (evt) ~>
    button = evt._target
    @load-events-button button, @kStatus.Loading
    App.ajax._post '/api/sampledata/create_stakeholders', null, do
      _success: (data) ~>
        tbl = ["<span>#{d.'document_number'} : (#{d.'document_type'}) - \
                #{d.'name'} </span><br/>" for d in data]
        @load-events-button button, @kStatus.Success, 'Stakeholders creados'
        @load-modal tbl.join ''
      _error: ~>
        @load-events-button button, @kStatus.Error, 'Error al crear Stakeholders'

  /**
   * Crear alertas
   */
  create-alerts: (evt) ~>
    button = evt._target
    @load-events-button button, @kStatus.Loading
    App.ajax._post '/api/sampledata/create_alerts', null, do
      _success: ~>
        @load-events-button button, @kStatus.Success, 'Alertas creadas'
      _error: ~>
        @load-events-button button, @kStatus.Error, 'Error al crear alertas'


  /**
   * Crear todos las tablas estaticas
   */
  create-all: (evt) ~>
    button = evt._target
    @load-events-button button, @kStatus.Loading
    App.ajax._post '/api/sampledata/execute_all', null, do
      _success: ~>
        @load-events-button button, @kStatus.Success, 'Todo ejecutado'
      _error: ~>
        @load-events-button button, @kStatus.Error, 'Error al ejecutar'

  /** @override */
  render: ->
    r = super!
    @el.html = ''

    ##########################################
    ## CREAR TODOS
    ###########################################
    b-all = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = '<label> Ejecutar todo</label>
                <small> - crea todas las tablas </small>'
      @el._append ..

    App.dom._new \button
      .._type = 'button'
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}"
      ..html = 'Ejecutar'
      ..on-click @create-all
      b-all._append ..

    ##########################################
    ## CREAR ALERTAS
    ###########################################
    b-alert = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = '<label> Crear alertas</label>
                <small> - crea todas las alertas (Anexo 1)</small>'
      @el._append ..

    App.dom._new \button
      .._type = 'button'
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}"
      ..html = 'Ejecutar'
      ..on-click @create-alerts
      b-alert._append ..


    ###########################################
    ## CREAR AGENCIA DE ADUANA
    ###########################################
    b-agency = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = '<label> Crear agencia de aduana</label>
                <small> - Se crea agencia por defecto.</small>'
      @el._append ..

    App.dom._new \button
      .._type = 'button'
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}"
      ..html = 'Ejecutar'
      ..on-click @create-agency
      b-agency._append ..

    ###########################################
    ## CREAR CLIENTES
    ###########################################
    b-customer = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = '<label> Crear clientes </label>
                <small> - Se creara por defecto los clientes.</small>'
      @el._append ..

    App.dom._new \button
      .._type = 'button'
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}"
      ..html = 'Ejecutar'
      ..on-click @create-customers
      b-customer._append ..

    ###########################################
    ## CREAR VINCULADOS(`STAKEHOLDERS`)
    ###########################################
    b-stakeholder = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = '<label> Crear Vinculados (Stakeholders) </label>'
      @el._append ..

    App.dom._new \button
      .._type = 'button'
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}"
      ..html = 'Ejecutar'
      ..on-click @create-stakeholders
      b-stakeholder._append ..

    r

/** @export */
module.exports = NoDependency


# vim: ts=2:sw=2:sts=2:et
