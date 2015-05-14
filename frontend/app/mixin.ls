/** @module app */


JSONAccessor = (_proto) ->
  _proto <<<
    _json:~
      -> @_json-getter!
      (_) -> @_json-setter ...

    _json-getter: ->
    _json-setter: ->


exports <<<
  JSONAccessor: JSONAccessor

# vim: ts=2:sw=2:sts=2:et
