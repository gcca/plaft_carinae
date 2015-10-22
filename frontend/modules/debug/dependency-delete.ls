/** @module modules.debug */

GenericBody = require './generic'

class RegisterBody extends GenericBody

  drop-all-dispatches: (evt) ~>
    button = evt._target
    button._old-name = button.html
    dto =
      'customs-agency': @customs-agency-id

    @load-events-button button, @kStatus.Loading

    App.ajax._post '/api/sampledata/drop_dispatches', dto , do
      _success: ~>
        @load-events-button button, @kStatus.Success
      _error: ~>
        @load-events-button button, @kStatus.Error

  /** @override */
  render: ->
    ret = super!

    ###########################################
    ## ELIMINAR LOS DESPACHOS
    ###########################################
    b-agency = App.dom._new \div
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-4}"
      ..html = '<label> Eliminar los despachos</label>
                <small> - de la agencia de aduana.</small>'
      @body._append ..

    App.dom._new \button
      .._type = 'button'
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}"
      ..html = 'Eliminar todos los despachos'
      ..on-click @drop-all-dispatches
      b-agency._append ..

    ret

/** @export */
module.exports = RegisterBody


# vim: ts=2:sw=2:sts=2:et
