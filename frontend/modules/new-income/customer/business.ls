/** @module modules.income */


class Business extends App.View

  /** @override */
  _tagName: \form

  _toJSON: ->
    r = @el._json!
    # TODO: Add sahreholders
    r

  /** @override */
  render: ->
    @el.html = 'Persona jurídica.'
    super!


/** @export */
module.exports = Business


# vim: ts=2:sw=2:sts=2:et
