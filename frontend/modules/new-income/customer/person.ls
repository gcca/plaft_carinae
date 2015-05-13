/** @module modules.income */


class Person extends App.View

  /** @override */
  _tagName: \form

  _toJSON: -> @el._json!

  /** @override */
  render: ->
    @el.html = 'Persona natural.'
    super!


/** @export */
module.exports = Person


# vim: ts=2:sw=2:sts=2:et
