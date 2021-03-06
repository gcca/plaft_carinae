/** @module app */

class exports.Customer extends App.Model

  /** @override */
  urlRoot: \customer

  is-business: ->
    _attrs = @_attributes
    _class = _attrs\class_
   # TODO(...): remove {@code Customer} validation:
   #   ensure {@code class} from backend constructino customer instance.
    if _class? and _class[*-1] isnt \Customer
      _class[*-1] is \Business
    else
      _attrs.'document'.'number'._length is 11

  is-person: ->
    not @is-business!


class exports.Dispatch extends App.Model

  urlRoot: 'dispatch'


class exports.Dispatches extends App.Collection

  model: Dispatch


# vim: ts=2:sw=2:sts=2:et
