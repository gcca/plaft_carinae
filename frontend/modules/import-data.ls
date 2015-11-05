/**
 * @module modules
 */
Module = require '../workspace-new/module'

class ImportData extends Module

  /** @override */
  _tagName: \form

  request-dispatch: ~>
    @_desktop._lock!
    @_desktop._spinner-start!
    _file = @dispatch.files[0]
    xhr = new XMLHttpRequest!
    fd = new FormData!

    xhr.open 'post', '/api/importdata/dispatch', true
    xhr.onreadystatechange = ~>
      if xhr.readyState == 4 and xhr.status == 200
        length = xhr.responseText

        @result.html = "Se han importado #{length} despachos al sistema."
        @_desktop._unlock!
        @_desktop._spinner-stop!

    fd.append 'data', _file
    xhr.send fd

  request-stakeholder: ~>
    @_desktop._lock!
    @_desktop._spinner-start!
    _file = @stakeholder.files[0]
    xhr = new XMLHttpRequest!
    fd = new FormData!

    xhr.open 'post', '/api/importdata/stakeholder', true
    xhr.onreadystatechange = ~>
      if xhr.readyState == 4 and xhr.status == 200
        length = xhr.responseText

        @result.html = "Se importo los datos de los stakeholders"
        @_desktop._unlock!
        @_desktop._spinner-stop!

    fd.append 'data', _file
    xhr.send fd

  /** @override */
  render: ->
    @el.html = "<h3>Por favor ingrese el documento excel (Formato: xls, xlsx)</h3>"

    ## Leer despachos
    App.dom._new \div
      .._class = "#{gz.Css \col-md-6} #{gz.Css \no-padding}"
      ..html = "<label>Leer data de los despachos</label>
                <input type='file' />
                <button type='button'
                        class='#{gz.Css \btn} #{gz.Css \btn-default}'>
                  Leer formato
                </button>"
      @dispatch = .._first._next
      btn-dispatch = .._last
      @el._append ..

    btn-dispatch.on-click @request-dispatch

    ## Leer `stakeholders`
    App.dom._new \div
      .._class = "#{gz.Css \col-md-6} #{gz.Css \no-padding}"
      ..html = "<label>Leer data de los vinculados</label>
                <input type='file' />
                <button type='button'
                        class='#{gz.Css \btn} #{gz.Css \btn-default}'>
                  Leer formato
                </button>"
      @stakeholder = .._first._next
      btn-stakeholder = .._last
      @el._append ..

    btn-stakeholder.on-click @request-stakeholder


    @result = App.dom._new \div
      .._class = gz.Css \col-md-12
      @el._append ..
    super!


  /** @private */ file: null
  /** @protected */ @@_mod-caption = 'IMPORTAR DATA'
  /** @protected */ @@_mod-icon    = gz.Css \road
  /** @protected */ @@_mod-hash    = 'auth-hash-import-data'

/** @exports */
module.exports = ImportData


/* vim: ts=2 sw=2 sts=2 et: */
