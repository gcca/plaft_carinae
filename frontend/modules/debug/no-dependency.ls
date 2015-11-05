/** @module modules.debug */

GenericBody = require './generic'

class NoDependency extends GenericBody

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
      .._class = "#{gz.Css \form-group} #{gz.Css \col-md-12}"
      ..html = '<label> Crear los documentos,
                      \ tablas de clientes,
                      \ tablas de vinculados y
                      \ diferentes de alertas</label>
                <small> - crea todas las tablas </small>'
      @el._append ..

    App.dom._new \button
      .._type = 'button'
      .._class = "#{gz.Css \btn}
                \ #{gz.Css \btn-default}"
      ..html = 'Ejecutar'
      ..on-click @create-all
      b-all._append ..

    r

/** @export */
module.exports = NoDependency


# vim: ts=2:sw=2:sts=2:et
