/** @module modules */

Module = require '../workspace-new/module'

/**
 */
class SubSubTestI extends Module

  _tagName: \div

  initialize: ({@text}) ->

  render: ->
    @el.html = "<h4>VALOR DE LA CAJA DE TEXTO#{@text}</h4>"
    super!

  @@_mod-caption = 'SUB - SUBMODULO TEST I'

/**
 */

/**
 */
class SubTestI extends Module

  _tagName: \div

  initialize: ({@text}) ->

  render: ->
    @el.html = "<h4>#{@text}</h4>"
    _input = App.dom._new \input
      .._type = 'text'
      .._value = 'por defecto'
      @el._append ..
    App.dom._new \button
      .._type = 'button'
      .._class = 'btn btn-primary'
      ..html = 'pasar a la otra pagina'
      ..on-click ~>
          @_desktop.load-sub-module(SubSubTestI, do
                                   text: _input._value)
      @el._append ..
    super!

  @@_mod-caption = 'SUBMODULO TEST I'
  @@_mod-group-buttons =
    * name: 'GUARDAR-I'
      callback: ~> console.log @text

    * name: 'MODIFICAR-II'
      callback: -> console.log 'Modificar'

/**
 */
class TestI extends Module

  _tagName: \div

  render: ->
    @el.html = "<h4>TEST MODULE I</h4>"
    App.dom._new \button
      .._type = 'button'
      .._class = 'btn btn-primary'
      ..html = 'pasar a la otra pagina'
      ..on-click ~>
          @_desktop.load-sub-module(SubTestI, do
                                   text: 'ENTRANDO AL SUBMODULO')
      @el._append ..
    super!

  @@_mod-caption = 'TEST - MODULE I'
  @@_mod-icon    = gz.Css \tags


/** @export */
module.exports = TestI


# vim: ts=2:sw=2:sts=2:et
