/** @module modules.debug */

GenericBody = require './generic'

class NoDependency extends GenericBody

  /**
   * Crear agencia de aduanas.
   */
  create-agency: (evt) ~>
    button = evt._target
    button._old-name = button.html
    @load-events-button button, @kStatus.Loading
    App.ajax._post '/api/sampledata/create_agency', null, do
      _success: (data) ~>
        mensaje = "<span>Agencia creada: <br/>
                   Nombre de agencia: #{data.'name'}<br/>
                   Oficial : #{data.'officer'.'name'}<br/>
                   Usuario : #{data.'officer'.'username'}
                   </span>"
        @load-events-button button, @kStatus.Success
        @load-modal mensaje
      _error: ~>
        @load-events-button button, @kStatus.Error

  /**
   * Crear clientes.
   */
  create-customers: (evt) ~>
    button = evt._target
    button._old-name = button.html
    @load-events-button button, @kStatus.Loading
    App.ajax._post '/api/sampledata/create_customers', null, do
      _success: (data) ~>
        tbl = ["<span>#{d.'document_number'} : (#{d.'document_type'}) - \
                #{d.'name'} </span><br/>" for d in data]
        @load-events-button button, @kStatus.Success
        @load-modal tbl.join ''
      _error: ~>
        @load-events-button button, @kStatus.Error

  /**
   * Crear stakeholders.
   */
  create-stakeholders: (evt) ~>
    button = evt._target
    button._old-name = button.html
    @load-events-button button, @kStatus.Loading
    App.ajax._post '/api/sampledata/create_stakeholders', null, do
      _success: (data) ~>
        tbl = ["<span>#{d.'document_number'} : (#{d.'document_type'}) - \
                #{d.'name'} </span><br/>" for d in data]
        @load-events-button button, @kStatus.Success
        @load-modal tbl.join ''
      _error: ~>
        @load-events-button button, @kStatus.Error

  /**
   * Crear alertas
   */
  create-alerts: (evt) ~>
    button = evt._target
    button._old-name = button.html
    @load-events-button button, @kStatus.Loading
    App.ajax._post '/api/sampledata/create_alerts', null, do
      _success: ~>
        @load-events-button button, @kStatus.Success
      _error: ~>
        @load-events-button button, @kStatus.Error


  /** @override */
  render: ->
    r = super!
    @el.html = ''

    ##########################################
    ## CREAR ALERTAS
    ###########################################
    b-alert = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = '<label> Crear alertas</label>
                <small> - alertas (Anexo 1)</small>'
      @el._append ..

    App.dom._new \button
      .._type = 'button'
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}"
      ..html = 'Crear Alertas'
      ..on-click @create-alerts
      b-alert._append ..


    ###########################################
    ## CREAR AGENCIA DE ADUANA
    ###########################################
    b-agency = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = '<label> Crear agencia de aduana</label>
                <small> - Se crea uno por defecto.</small>'
      @el._append ..

    App.dom._new \button
      .._type = 'button'
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}"
      ..html = 'Crear Agencia de Aduana'
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
      ..html = 'Crear clientes'
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
      ..html = 'Crear Vinculados'
      ..on-click @create-stakeholders
      b-stakeholder._append ..

    r



/** @export */
module.exports = NoDependency


# vim: ts=2:sw=2:sts=2:et
