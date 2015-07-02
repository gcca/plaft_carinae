/** @module */


ajax_base = (_type, [_url, _data, _options]) ->
  $\ajax do
    \type        : _type
    \url         : _url
    \data        : JSON.stringify _data
    \statusCode  : {[RC[k], v] for k, v of _options}
    \contentType : 'application/json'
    \dataType    : \json


RC =
  _success: 200
  _bad-request: 400
  _not-found: 404

/** @export */
exports <<<
  _get: (_url, _async, _data, _options) ->
    if not _options?
      _options = _data
      _data = null
    $\ajax do
      \url        : _url
      \async      : _async
      \data       : _data
      \statusCode : {[RC[k], v] for k, v of _options}

  _post: ->
    ajax_base \POST, &

  _put: ->
    ajax_base \PUT, &

  _delete: ->
    &.2 = &.1
    &.1 = undefined
    ajax_base \DELETE, &


# vim: ts=2:sw=2:sts=2:et
