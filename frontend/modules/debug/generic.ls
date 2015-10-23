/** @module modules.debug */

panelgroup = App.widget.panelgroup
modal = App.widget.message-box
Modal = modal.Modal

class GenericBody extends panelgroup.JSONBody

  /** @override */
  _tagName: \div

  /**
   * Carga un Modal
   */
  load-modal: (element) ->
    mdl = Modal._new do
        _title: 'Resultado'
        _body: element
    mdl._show!

  toggle-class: (ele, _class) ->
    for k in Object.keys @kButtons
      ele._class._remove @kButtons[k]
    ele._class._add _class

  /**
   * Bloquea o desbloquea los botones
   */
  all-buttons: (disabled) ->
    buttons = @el.queryAll 'button'
    for button in buttons
      button._disabled = disabled

  /**
   * Cambia la clase del boton.
   */
  load-events-button: (button, status, message) ->
    | status is @kStatus.Loading =>
      @toggle-class button, @kButtons.Info
      @all-buttons true
      button.html = 'Ejecutando ...'

    | status is @kStatus.Success =>
      @toggle-class button, @kButtons.Success
      button.html = message

      set-timeout ( ~>
                    @toggle-class button, @kButtons.Default
                    button.html = 'Ejecutar'
                    @all-buttons false),
                   2500

    | status is @kStatus.Error =>
      @toggle-class button, @kButtons.Danger
      button.html = message

      set-timeout ( ~>
                    @toggle-class button, @kButtons.Default
                    button.html = 'Ejecutar'
                    @all-buttons false),
                   2500

  /**
   * Cambiar ID de agencia de aduana.
   */
  change-customs-id: (select) ->
    @customs-agency-id = select._value

  /**
   * Cargar agencias de aduana.
   */
  load-select: ~>
    App.ajax._get '/api/customs_agency', true, do
      _success: (agencies) ~>
        @customs-agencies.html = ''
        for agency in agencies
          App.dom._new \option
            .._value = agency.'id'
            ..html = agency.'name'
            @customs-agencies._append ..
        @change-customs-id @customs-agencies

  /** @override */
  render: ->
    r = super!

    header =  App.dom._new \div
      .._class = "#{gz.Css \col-md-6} #{gz.Css \center-block}"
      ..css = 'margin-bottom: 30px'
      ..html = '<label>Escoga un agencia de aduana</label>'
      @el._append ..

    @body = App.dom._new \div
      .._class = "#{gz.Css \col-md-12} #{gz.Css \no-padding}"
      @el._append ..

    ###########################################
    ## Combo agencias
    ###########################################
    App.dom._new \button
      .._class = "#{gz.Css \btn} #{gz.Css \btn-default}"
      ..css = 'margin-left: 15px'
      ..html = "<i class='#{gz.Css \glyphicon} #{gz.Css \glyphicon-refresh}'></i>"
      ..on-click @load-select
      header._append ..

    @customs-agencies = App.dom._new \select
      .._class = gz.Css \form-control
      ..on-change (evt) ~>
        @change-customs-id evt._target
      header._append ..

    ##  CARGA TODOS LAS AGENCIAS DE ADUANA   ##
    @load-select!

    r


  kStatus:
    Loading : 1
    Success : 2
    Error   : 4

  kButtons:
    Success: gz.Css \btn-success
    Danger : gz.Css \btn-danger
    Info   : gz.Css \btn-info
    Default: gz.Css \btn-default

  /** @private */ customs-agency-id: null
  /** @private */ customs-agencies: null
  /** @private */ body: null

/** @export */
module.exports = GenericBody


# vim: ts=2:sw=2:sts=2:et
