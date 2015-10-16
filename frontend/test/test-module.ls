/** @module modules */

Module = require '../workspace-new/module'
FieldType = App.builtins.Types.Field

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

  first-button: ->
    console.log 'FIRST BUTTON'
    console.log @text


  initialize: ({@text}) -> super!

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
    @div-a = App.dom._new \h1
      @el._append ..

    super!

  div-a: null
  @@_mod-caption = 'SUBMODULO TEST I'
  _mod-group-buttons:
    * caption: 'Grupo I'
      type: FieldType.kComboBox
      options:
        * caption: 'Ingresar'
          callback: ->
            console.log 'SubMenu - Ingresar'
            console.log @text
            @first-button!
        * caption: 'Modificar'
          callback: ->
            console.log 'SubMenu - Modificar'
            console.log @text
        * caption: 'Eliminar'
          callback: ->
            console.log 'SubMenu - Eliminar'
            console.log @text

    * caption: 'radio-module'
      type: FieldType.kRadioGroup
      options: <[Primera Segunda Tercera]>
      callback: (element) ->
        @div-a.html = element._value

    * caption: 'check-module'
      type: FieldType.kCheckBox
      options: <[check1 check2 check3]>
      callback: (element) ->
        console.log element

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
  @@_mod-icon    = gz.Css \print


/** @export */
module.exports = TestI


# vim: ts=2:sw=2:sts=2:et
