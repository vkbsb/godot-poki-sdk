extends Node

const BRIDGE_NAME := "PokiGodotBridge"

var sdk_handle = null
var _next_callback_id := 1
var _retained_js_references := {}
var _display_ad_callback_ids := {}

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
	if OS.has_feature("web") == false:
		return

	sdk_handle = JavaScriptBridge.get_interface(BRIDGE_NAME)
	if not sdk_handle:
		return


func commercialBreak(on_start = null):
	if not _has_sdk():
		return

	var callback_id = _reserve_callback_id()
	var promise = null
	if _is_valid_callable(on_start):
		promise = sdk_handle.commercialBreak(
			_create_js_callback(Callable(self, "_invoke_no_arg_callable").bind(on_start), callback_id)
		)
	else:
		promise = sdk_handle.commercialBreak()

	_attach_promise_with_args(
		promise,
		callback_id,
		"commercial_break_done",
		"commercial_break_failed",
		true
	)


func rewardedBreak(on_start_or_params = null):
	if not _has_sdk():
		return

	var callback_id = _reserve_callback_id()
	var promise = null

	if _is_valid_callable(on_start_or_params):
		var on_start_callback = _create_js_callback(
			Callable(self, "_invoke_no_arg_callable").bind(on_start_or_params),
			callback_id
		)
		promise = sdk_handle.rewardedBreak(on_start_callback)
	elif on_start_or_params is Dictionary:
		var params: Dictionary = on_start_or_params
		var js_params = JavaScriptBridge.create_object("Object")
		if params.has("size") and params["size"] != null:
			js_params.size = str(params["size"]).to_lower()
		if params.has("onStart") and _is_valid_callable(params["onStart"]):
			js_params.onStart = _create_js_callback(
				Callable(self, "_invoke_no_arg_callable").bind(params["onStart"]),
				callback_id
			)
		promise = sdk_handle.rewardedBreak(js_params)
	else:
		promise = sdk_handle.rewardedBreak()

	_attach_promise_with_args(
		promise,
		callback_id,
		"rewarded_break_done",
		"rewarded_break_failed",
		true
	)


func shareableURL(params: Dictionary = {}):
	if not _has_sdk():
		return

	_attach_promise(
		sdk_handle.shareableURL(_dictionary_to_js_object(params)),
		"shareable_url_ready",
		"shareable_url_failed",
		true
	)


func getUser():
	if not _has_sdk():
		return

	_attach_promise(
		sdk_handle.getUser(),
		"user_ready",
		"user_failed",
		true,
		Callable(self, "_normalize_user")
	)


func getToken():
	if not _has_sdk():
		return

	_attach_promise(sdk_handle.getToken(), "token_ready", "token_failed", true)


func login():
	if not _has_sdk():
		return

	_attach_promise(sdk_handle.login(), "login_done", "login_failed", false)


func displayAd(container, size = null, on_can_destroy = null, on_display_rendered = null):
	if not _has_sdk():
		return

	var args := [container, size]
	var callback_id = -1
	var container_key = _container_key(container)

	if _is_valid_callable(on_can_destroy) or _is_valid_callable(on_display_rendered):
		callback_id = _reserve_callback_id()
		if _display_ad_callback_ids.has(container_key):
			_release_callback_group(_display_ad_callback_ids[container_key])

	if _is_valid_callable(on_can_destroy):
		args.append(
			_create_js_callback(
				Callable(self, "_on_display_ad_can_destroy").bind(on_can_destroy, callback_id, container_key),
				callback_id
			)
		)
	else:
		args.append(null)

	if _is_valid_callable(on_display_rendered):
		args.append(
			_create_js_callback(
				Callable(self, "_on_display_ad_rendered").bind(on_display_rendered),
				callback_id
			)
		)

	if callback_id != -1:
		_display_ad_callback_ids[container_key] = callback_id

	sdk_handle.displayAd(args[0], args[1], args[2] if args.size() > 2 else null, args[3] if args.size() > 3 else null)


func destroyAd(container):
	if not _has_sdk():
		return

	sdk_handle.destroyAd(container)
	var container_key = _container_key(container)
	if _display_ad_callback_ids.has(container_key):
		_release_callback_group(_display_ad_callback_ids[container_key])
		_display_ad_callback_ids.erase(container_key)


func getURLParam(key: String) -> String:
	if not _has_sdk():
		return ""

	var value = sdk_handle.getURLParam(key)
	if value == null:
		return ""
	return str(value)


func getLanguage() -> String:
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


func setDebug(toggle: bool):
	if not _has_sdk():
		return

	sdk_handle.setDebug(toggle)


func setLogging(toggle: bool):
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


func openExternalLink(url: String):
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


func movePill(top_percent: float, top_px: float):
	if not _has_sdk():
		return

	sdk_handle.movePill(top_percent, top_px)


func measure(category: String, what: String, action: String):
	if not _has_sdk():
		return

	sdk_handle.measure(category, what, action)


func isAdBlocked() -> bool:
	if not _has_sdk():
		return false

	var value = sdk_handle.isAdBlocked()
	return bool(value)


func _has_sdk() -> bool:
	return sdk_handle != null


func _attach_promise(promise, success_signal: StringName, failure_signal: StringName, emit_payload: bool, transformer: Callable = Callable()):
	var callback_id = _reserve_callback_id()
	_attach_promise_with_args(promise, callback_id, success_signal, failure_signal, emit_payload, transformer)


func _attach_promise_with_args(
	promise,
	callback_id: int,
	success_signal: StringName,
	failure_signal: StringName,
	emit_payload: bool,
	transformer: Callable = Callable()
):
	var resolve_callback = _create_js_callback(
		Callable(self, "_on_promise_resolved").bind(success_signal, callback_id, emit_payload, transformer),
		callback_id
	)
	var reject_callback = _create_js_callback(
		Callable(self, "_on_promise_rejected").bind(failure_signal, callback_id),
		callback_id
	)
	promise.then(resolve_callback).catch(reject_callback)


func _create_js_callback(callback: Callable, callback_id: int):
	var js_callback = JavaScriptBridge.create_callback(callback)
	if not _retained_js_references.has(callback_id):
		_retained_js_references[callback_id] = []
	_retained_js_references[callback_id].append(js_callback)
	return js_callback


func _reserve_callback_id() -> int:
	var callback_id = _next_callback_id
	_next_callback_id += 1
	_retained_js_references[callback_id] = []
	return callback_id


func _release_callback_group(callback_id: int):
	_retained_js_references.erase(callback_id)


func _on_promise_resolved(args, success_signal: StringName, callback_id: int, emit_payload: bool, transformer: Callable = Callable()):
	var value = _first_callback_arg(args)
	if transformer.is_valid():
		value = transformer.call(value)
	_release_callback_group(callback_id)

	if emit_payload:
		emit_signal(success_signal, value)
		return

	emit_signal(success_signal)


func _on_promise_rejected(args, failure_signal: StringName, callback_id: int):
	var error_text = _normalize_error(_first_callback_arg(args))
	_release_callback_group(callback_id)
	emit_signal(failure_signal, error_text)


func _invoke_no_arg_callable(_args, callback: Callable):
	if callback.is_valid():
		callback.call()


func _on_display_ad_can_destroy(_args, callback: Callable, callback_id: int, container_key: String):
	if callback.is_valid():
		callback.call()

	_release_callback_group(callback_id)
	if _display_ad_callback_ids.get(container_key, -1) == callback_id:
		_display_ad_callback_ids.erase(container_key)


func _on_display_ad_rendered(args, callback: Callable):
	if not callback.is_valid():
		return

	callback.call(bool(_first_callback_arg(args)))


func _first_callback_arg(args):
	if args is Array and args.size() > 0:
		return args[0]
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


func _normalize_error(error_value) -> String:
	if error_value == null:
		return "Unknown Poki SDK error"

	if error_value is String:
		return error_value

	if error_value is JavaScriptObject:
		if error_value.message != null and str(error_value.message) != "":
			return str(error_value.message)
		if error_value.toString != null:
			return str(error_value.toString())

	return str(error_value)


func _dictionary_to_js_object(source: Dictionary, excluded_keys: Array = []):
	var js_object = JavaScriptBridge.create_object("Object")
	for key in source.keys():
		if excluded_keys.has(key):
			continue
		js_object[key] = _to_js_value(source[key])
	return js_object


func _array_to_js_array(source: Array):
	var js_array = JavaScriptBridge.create_object("Array")
	for item in source:
		js_array.push(_to_js_value(item))
	return js_array


func _to_js_value(value):
	if value is Dictionary:
		return _dictionary_to_js_object(value)
	if value is Array:
		return _array_to_js_array(value)
	return value


func _is_valid_callable(value) -> bool:
	return value is Callable and value.is_valid()


func _container_key(container) -> String:
	return str(container)
