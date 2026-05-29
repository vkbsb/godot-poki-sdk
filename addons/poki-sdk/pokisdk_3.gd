extends Node

const BRIDGE_NAME = "PokiGodotBridge"

var sdk_handle = null
var _next_callback_id = 1
var _callbacks = {}
var _display_ad_callback_ids = {}
var _commercial_start_callback_id = -1
var _rewarded_start_callback_id = -1

var _javascript = null
var _bridge_callback = null
var _commercial_resolve_callback = null
var _commercial_reject_callback = null
var _rewarded_resolve_callback = null
var _rewarded_reject_callback = null
var _shareable_resolve_callback = null
var _shareable_reject_callback = null
var _user_resolve_callback = null
var _user_reject_callback = null
var _token_resolve_callback = null
var _token_reject_callback = null
var _login_resolve_callback = null
var _login_reject_callback = null

signal commercial_break_done(response)
signal commercial_break_failed(error)
signal rewarded_break_done(response)
signal rewarded_break_failed(error)
signal shareable_url_ready(url)
signal shareable_url_failed(error)
signal user_ready(user)
signal user_failed(error)
signal token_ready(token)
signal token_failed(error)
signal login_done
signal login_failed(error)


func _ready():
	if OS.has_feature("JavaScript") == false:
		return

	_javascript = Engine.get_singleton("JavaScript")
	if _javascript == null:
		return

	sdk_handle = _javascript.get_interface(BRIDGE_NAME)
	if not sdk_handle:
		return

	_bridge_callback = _javascript.create_callback(self, "_on_bridge_callback")
	sdk_handle.setGodotCallback(_bridge_callback)

	_commercial_resolve_callback = _javascript.create_callback(self, "_on_commercial_break_resolved")
	_commercial_reject_callback = _javascript.create_callback(self, "_on_commercial_break_rejected")
	_rewarded_resolve_callback = _javascript.create_callback(self, "_on_rewarded_break_resolved")
	_rewarded_reject_callback = _javascript.create_callback(self, "_on_rewarded_break_rejected")
	_shareable_resolve_callback = _javascript.create_callback(self, "_on_shareable_url_resolved")
	_shareable_reject_callback = _javascript.create_callback(self, "_on_shareable_url_rejected")
	_user_resolve_callback = _javascript.create_callback(self, "_on_user_resolved")
	_user_reject_callback = _javascript.create_callback(self, "_on_user_rejected")
	_token_resolve_callback = _javascript.create_callback(self, "_on_token_resolved")
	_token_reject_callback = _javascript.create_callback(self, "_on_token_rejected")
	_login_resolve_callback = _javascript.create_callback(self, "_on_login_resolved")
	_login_reject_callback = _javascript.create_callback(self, "_on_login_rejected")


func commercialBreak(on_start = null):
	if not _has_sdk():
		return

	var promise = null
	if _is_valid_callback(on_start):
		_commercial_start_callback_id = _reserve_callback_id()
		_callbacks[_commercial_start_callback_id] = on_start
		promise = sdk_handle.commercialBreak(_commercial_start_callback_id)
	else:
		promise = sdk_handle.commercialBreak()

	_attach_promise(promise, _commercial_resolve_callback, _commercial_reject_callback)


func rewardedBreak(on_start_or_params = null):
	if not _has_sdk():
		return

	var promise = null
	if _is_valid_callback(on_start_or_params):
		_rewarded_start_callback_id = _reserve_callback_id()
		_callbacks[_rewarded_start_callback_id] = on_start_or_params
		promise = sdk_handle.rewardedBreak(_rewarded_start_callback_id)
	elif on_start_or_params is Dictionary:
		var params = on_start_or_params
		var js_params = _javascript.create_object("Object")
		if params.has("size") and params["size"] != null:
			js_params.size = str(params["size"]).to_lower()
		if params.has("onStart") and _is_valid_callback(params["onStart"]):
			_rewarded_start_callback_id = _reserve_callback_id()
			_callbacks[_rewarded_start_callback_id] = params["onStart"]
			js_params.onStart = _rewarded_start_callback_id
		promise = sdk_handle.rewardedBreak(js_params)
	else:
		promise = sdk_handle.rewardedBreak()

	_attach_promise(promise, _rewarded_resolve_callback, _rewarded_reject_callback)


func shareableURL(params = {}):
	if not _has_sdk():
		return

	_attach_promise(
		sdk_handle.shareableURL(_dictionary_to_js_object(params)),
		_shareable_resolve_callback,
		_shareable_reject_callback
	)


func getUser():
	if not _has_sdk():
		return

	_attach_promise(sdk_handle.getUser(), _user_resolve_callback, _user_reject_callback)


func getToken():
	if not _has_sdk():
		return

	_attach_promise(sdk_handle.getToken(), _token_resolve_callback, _token_reject_callback)


func login():
	if not _has_sdk():
		return

	_attach_promise(sdk_handle.login(), _login_resolve_callback, _login_reject_callback)


func displayAd(container, size = null, on_can_destroy = null, on_display_rendered = null):
	if not _has_sdk():
		return

	var callback_id = -1
	var container_key = _container_key(container)
	var has_can_destroy = _is_valid_callback(on_can_destroy)
	var has_display_rendered = _is_valid_callback(on_display_rendered)
	if has_can_destroy or has_display_rendered:
		callback_id = _reserve_callback_id()
		_callbacks[callback_id] = {
			"can_destroy": on_can_destroy,
			"rendered": on_display_rendered,
		}
		if _display_ad_callback_ids.has(container_key):
			_release_callback_group(_display_ad_callback_ids[container_key])
		_display_ad_callback_ids[container_key] = callback_id

	if callback_id != -1:
		sdk_handle.displayAd(container, size, callback_id, has_can_destroy, has_display_rendered)
		return

	if size == null:
		sdk_handle.displayAd(container)
		return

	sdk_handle.displayAd(container, size)


func destroyAd(container):
	if not _has_sdk():
		return

	sdk_handle.destroyAd(container)
	var container_key = _container_key(container)
	if _display_ad_callback_ids.has(container_key):
		_release_callback_group(_display_ad_callback_ids[container_key])
		_display_ad_callback_ids.erase(container_key)


func getURLParam(key):
	if not _has_sdk():
		return ""

	var value = sdk_handle.getURLParam(key)
	if value == null:
		return ""
	return str(value)


func getLanguage():
	if not _has_sdk():
		return ""

	var value = sdk_handle.getLanguage()
	if value == null:
		return ""
	return str(value)


func captureError(err):
	if not _has_sdk():
		return

	sdk_handle.captureError(err)


func gameLoadingFinished():
	if not _has_sdk():
		return

	sdk_handle.gameLoadingFinished()


func gameplayStart():
	if not _has_sdk():
		return

	sdk_handle.gameplayStart()


func gameplayStop():
	if not _has_sdk():
		return

	sdk_handle.gameplayStop()


func setDebug(toggle):
	if not _has_sdk():
		return

	sdk_handle.setDebug(toggle)


func setLogging(toggle):
	if not _has_sdk():
		return

	sdk_handle.setLogging(toggle)


func enableEventTracking(cmp_index = null):
	if not _has_sdk():
		return

	if cmp_index == null:
		sdk_handle.enableEventTracking()
		return

	sdk_handle.enableEventTracking(cmp_index)


func openExternalLink(url):
	if not _has_sdk():
		return

	sdk_handle.openExternalLink(url)


func playtestSetCanvas(canvas_or_canvases = null):
	if not _has_sdk():
		return

	if canvas_or_canvases is Array:
		sdk_handle.playtestSetCanvas(_array_to_js_array(canvas_or_canvases))
		return

	sdk_handle.playtestSetCanvas(canvas_or_canvases)


func playtestCaptureHtmlOnce():
	if not _has_sdk():
		return

	sdk_handle.playtestCaptureHtmlOnce()


func playtestCaptureHtmlForce():
	if not _has_sdk():
		return

	sdk_handle.playtestCaptureHtmlForce()


func playtestCaptureHtmlOn():
	if not _has_sdk():
		return

	sdk_handle.playtestCaptureHtmlOn()


func playtestCaptureHtmlOff():
	if not _has_sdk():
		return

	sdk_handle.playtestCaptureHtmlOff()


func movePill(top_percent, top_px):
	if not _has_sdk():
		return

	sdk_handle.movePill(top_percent, top_px)


func measure(category, what, action):
	if not _has_sdk():
		return

	sdk_handle.measure(category, what, action)


func isAdBlocked():
	if not _has_sdk():
		return false

	return bool(sdk_handle.isAdBlocked())


func _has_sdk():
	return sdk_handle != null


func _attach_promise(promise, resolve_callback, reject_callback):
	if promise == null:
		return

	promise.then(resolve_callback).catch(reject_callback)


func _reserve_callback_id():
	var callback_id = _next_callback_id
	_next_callback_id += 1
	return callback_id


func _release_callback_group(callback_id):
	_callbacks.erase(callback_id)


func _on_bridge_callback(args):
	var event_name = str(_callback_arg(args, 0))
	var callback_id = int(_callback_arg(args, 1))
	var value = _callback_arg(args, 2)

	if event_name == "callback":
		_invoke_callback_by_id(callback_id, [])
	elif event_name == "display_can_destroy":
		_on_display_ad_can_destroy(callback_id)
	elif event_name == "display_rendered":
		_on_display_ad_rendered(callback_id, value)


func _on_commercial_break_resolved(args):
	_release_callback_group(_commercial_start_callback_id)
	_commercial_start_callback_id = -1
	emit_signal("commercial_break_done", _callback_arg(args, 0))


func _on_commercial_break_rejected(args):
	_release_callback_group(_commercial_start_callback_id)
	_commercial_start_callback_id = -1
	emit_signal("commercial_break_failed", _normalize_error(_callback_arg(args, 0)))


func _on_rewarded_break_resolved(args):
	_release_callback_group(_rewarded_start_callback_id)
	_rewarded_start_callback_id = -1
	emit_signal("rewarded_break_done", _callback_arg(args, 0))


func _on_rewarded_break_rejected(args):
	_release_callback_group(_rewarded_start_callback_id)
	_rewarded_start_callback_id = -1
	emit_signal("rewarded_break_failed", _normalize_error(_callback_arg(args, 0)))


func _on_shareable_url_resolved(args):
	emit_signal("shareable_url_ready", _callback_arg(args, 0))


func _on_shareable_url_rejected(args):
	emit_signal("shareable_url_failed", _normalize_error(_callback_arg(args, 0)))


func _on_user_resolved(args):
	emit_signal("user_ready", _normalize_user(_callback_arg(args, 0)))


func _on_user_rejected(args):
	emit_signal("user_failed", _normalize_error(_callback_arg(args, 0)))


func _on_token_resolved(args):
	emit_signal("token_ready", _callback_arg(args, 0))


func _on_token_rejected(args):
	emit_signal("token_failed", _normalize_error(_callback_arg(args, 0)))


func _on_login_resolved(_args):
	emit_signal("login_done")


func _on_login_rejected(args):
	emit_signal("login_failed", _normalize_error(_callback_arg(args, 0)))


func _invoke_callback_by_id(callback_id, args):
	if not _callbacks.has(callback_id):
		return

	_call_callback(_callbacks[callback_id], args)


func _on_display_ad_can_destroy(callback_id):
	if not _callbacks.has(callback_id):
		return

	var entry = _callbacks[callback_id]
	if entry is Dictionary:
		_call_callback(entry.get("can_destroy"), [])
	_release_callback_group(callback_id)
	_erase_display_callback_id(callback_id)


func _on_display_ad_rendered(callback_id, rendered):
	if not _callbacks.has(callback_id):
		return

	var entry = _callbacks[callback_id]
	if entry is Dictionary:
		_call_callback(entry.get("rendered"), [bool(rendered)])


func _erase_display_callback_id(callback_id):
	for key in _display_ad_callback_ids.keys():
		if _display_ad_callback_ids[key] == callback_id:
			_display_ad_callback_ids.erase(key)
			return


func _callback_arg(args, index):
	if args is Array and args.size() > index:
		return args[index]
	return null


func _normalize_user(user):
	if user == null:
		return null

	if user is Dictionary:
		return {
			"username": str(user.get("username", "")),
			"avatarUrl": str(user.get("avatarUrl", "")),
		}

	return {
		"username": str(user.username),
		"avatarUrl": str(user.avatarUrl),
	}


func _normalize_error(error_value):
	if error_value == null:
		return "Unknown Poki SDK error"

	if error_value is String:
		return error_value

	if typeof(error_value) == TYPE_OBJECT:
		if error_value.message != null and str(error_value.message) != "":
			return str(error_value.message)
		if error_value.toString != null:
			return str(error_value.toString())

	return str(error_value)


func _dictionary_to_js_object(source, excluded_keys = []):
	var js_object = _javascript.create_object("Object")
	for key in source.keys():
		if excluded_keys.has(key):
			continue
		js_object[key] = _to_js_value(source[key])
	return js_object


func _array_to_js_array(source):
	var js_array = _javascript.create_object("Array")
	for item in source:
		js_array.push(_to_js_value(item))
	return js_array


func _to_js_value(value):
	if value is Dictionary:
		return _dictionary_to_js_object(value)
	if value is Array:
		return _array_to_js_array(value)
	return value


func _is_valid_callback(value):
	if value == null:
		return false
	if typeof(value) != TYPE_OBJECT:
		return false
	if not value.has_method("call_func"):
		return false
	if value.has_method("is_valid"):
		return value.is_valid()
	return true


func _call_callback(callback, args):
	if not _is_valid_callback(callback):
		return

	if args.size() == 0:
		callback.call_func()
	elif args.size() == 1:
		callback.call_func(args[0])
	else:
		callback.call_funcv(args)


func _container_key(container):
	return str(container)
