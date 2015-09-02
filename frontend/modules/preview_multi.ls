/**
 * @module modules
 * @author gcca@gcca.tk (cristHian Gz. <gcca>)
 */

Module = require '../workspace/module'
table = App.widget.table
  Table = ..Table


class Multi extends App.Model


class MultiCollection extends App.Collection
  model: Multi


class PreviewMulti extends Module

  render: ->
    @_desktop._lock!
    @_desktop._spinner-start!

    App.model.Dispatches._all (dispatches) ~>
    # '/api/dispatch/list'
      dispatches = [.._attributes for dispatches._models]
      dispatches = [.. for dispatches \
                    when ..'amount' and (parseFloat ..'amount') < 10000]

      by-customer = new Object

      for dispatch in dispatches
        _key = dispatch.'customer'.'document_number'
        if not by-customer[_key]
          by-customer[_key] = new Array
        by-customer[_key]._push dispatch

      _table = new Table  do
        _attributes: <[customer dispatches score]>
        _labels:
          'Cliente'
          '<div>
             Despachos
             <br><span>Orden
                       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                       &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                       Monto</span>
           </div>'
          '<span style=\'padding-right:10em\'>Total</span>'
        _column-cell-style:
          'customer': 'text-overflow:ellipsis;
                       white-space:nowrap;
                       overflow:hidden;
                       max-width:27ch;
                       text-align:left;'
          'score': 'padding-right:10em'

      _table.set-rows new MultiCollection [new Multi { \
          'customer': by-customer[k].0.'customer'.'name', \
          'dispatches': "
            <ul style='list-style:none;padding-left:0'>
            #{["<li>
                  #{..'order'}
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                  #{..'amount'}</li>" \
               for by-customer[k]]._join ''}
            </ul>", \
          'score': _.'reduce' ([..'amount' \
                              for by-customer[k]]), \
                              (n, ax) -> n + ax \
      } for k of by-customer]

      @el._append _table.render!.el

      @_desktop._unlock!
      @_desktop._spinner-stop!

    super!

  /** @protected */ @@_caption = 'OPERACIONES MÚLTIPLES (EVAL. MONTOS)'
  /** @protected */ @@_icon    = gz.Css \print
  /** @protected */ @@_hash    = 'auth-hash-preview_multi'


/** @export */
module.exports = PreviewMulti


/* vim: ts=2 sw=2 sts=2 et: */
