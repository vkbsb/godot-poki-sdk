extends Control


func _enter_tree():
	var version = Engine.get_version_info()
	var major = int(version.get("major", 3))
	var script = null
	if major >= 4:
		script = _load_godot4_script()
	else:
		script = _load_godot3_script()

	if script == null:
		push_error("Could not load Poki SDK demo script")
		return

	set_script(script)


func _load_godot4_script():
	var loader_script = load("res://addons/demo/demo_4.gd")
	if loader_script == null:
		return null

	var loader = loader_script.new()
	if loader == null or not loader.has_method("create_script"):
		return null

	return loader.create_script()


func _load_godot3_script():
	var script = GDScript.new()
	script.source_code = _godot3_header() + _godot3_signal_connections() + _godot3_body()
	script.resource_path = "res://addons/demo/demo_3.gd"
	if script.reload() != OK:
		return null

	return script


func _godot3_header():
	return """
extends Control


func _ready():
"""


func _godot3_signal_connections():
	var connections = [
		["commercial_break_done", "_on_commercial_break_done"],
		["commercial_break_failed", "_on_commercial_break_failed"],
		["rewarded_break_done", "_on_reward_break_done"],
		["rewarded_break_failed", "_on_reward_break_failed"],
		["shareable_url_ready", "_on_shareable_url_ready"],
		["shareable_url_failed", "_on_shareable_url_failed"],
		["user_ready", "_on_user_ready"],
		["user_failed", "_on_user_failed"],
		["token_ready", "_on_token_ready"],
		["token_failed", "_on_token_failed"],
		["login_done", "_on_login_done"],
		["login_failed", "_on_login_failed"],
	]
	var source = ""
	for connection in connections:
		source += "\tPokiSDK.con" + "nect(\"%s\", self, \"%s\")\n" % [connection[0], connection[1]]
	return source


func _godot3_body():
	return """

	PokiSDK.gameplayStart()
	PokiSDK.measure("demo", "scene", "ready")

	$MarginContainer/PanelContainer/MainColumn/UrlParamLabel.text = "URL param (id): %s" % PokiSDK.getURLParam("id")
	$MarginContainer/PanelContainer/MainColumn/AdBlockedLabel.text = "Ad blocked: %s" % PokiSDK.isAdBlocked()
	_set_status("Demo ready")


func _on_commercial_break_done(_response):
	_resume_after_ad()
	_set_status("Commercial break finished")


func _on_commercial_break_failed(error):
	_resume_after_ad()
	_set_status("Commercial break failed: %s" % error)


func _on_reward_break_done(success):
	_resume_after_ad()
	if success:
		_set_status("Reward granted")
	else:
		_set_status("Reward not granted")


func _on_reward_break_failed(error):
	_resume_after_ad()
	_set_status("Rewarded break failed: %s" % error)


func _on_shareable_url_ready(url):
	$MarginContainer/PanelContainer/MainColumn/ShareUrlLineEdit.text = str(url)
	_set_status("Shareable URL created")


func _on_shareable_url_failed(error):
	_set_status("Shareable URL failed: %s" % error)


func _on_user_ready(user):
	if user == null:
		$MarginContainer/PanelContainer/MainColumn/UserLabel.text = "User: not logged in"
		_set_status("No user logged in")
		return

	$MarginContainer/PanelContainer/MainColumn/UserLabel.text = "User: %s" % user["username"]
	_set_status("Fetched user")


func _on_user_failed(error):
	_set_status("getUser failed: %s" % error)


func _on_token_ready(token):
	if token == null or token == "":
		$MarginContainer/PanelContainer/MainColumn/TokenLabel.text = "Token: unavailable"
		_set_status("No token available")
		return

	$MarginContainer/PanelContainer/MainColumn/TokenLabel.text = "Token: %s..." % str(token).substr(0, 32)
	_set_status("Fetched token")


func _on_token_failed(error):
	_set_status("getToken failed: %s" % error)


func _on_login_done():
	_set_status("Login completed or user already authenticated")


func _on_login_failed(error):
	_set_status("Login failed: %s" % error)


func _resume_after_ad():
	PokiSDK.gameplayStart()


func _pause_for_ad():
	PokiSDK.gameplayStop()


func _on_ad_started():
	print("Ad started")


func _set_status(message):
	$MarginContainer/PanelContainer/MainColumn/StatusLabel.text = "Status: %s" % message
	print(message)


func _on_CommercialBreakButton_pressed():
	_pause_for_ad()
	PokiSDK.commercialBreak(funcref(self, "_on_ad_started"))


func _on_RewardedBreakButton_pressed():
	_pause_for_ad()
	PokiSDK.rewardedBreak({
		"size": "medium",
		"onStart": funcref(self, "_on_ad_started"),
	})


func _on_ShareableUrlButton_pressed():
	$MarginContainer/PanelContainer/MainColumn/ShareUrlLineEdit.text = ""
	PokiSDK.shareableURL({
		"id": "demo-user",
		"type": "reward",
		"score": 42,
	})
	_set_status("Shareable URL requested")


func _on_GetUserButton_pressed():
	PokiSDK.getUser()
	_set_status("User requested")


func _on_GetTokenButton_pressed():
	PokiSDK.getToken()
	_set_status("Token requested")


func _on_LoginButton_pressed():
	PokiSDK.login()
	_set_status("Login requested")


func _on_MovePillButton_pressed():
	PokiSDK.movePill(0, 0)
	_set_status("Moved Poki Pill to 0,0")


func _on_MeasureButton_pressed():
	PokiSDK.measure("demo", "button", "measure")
	_set_status("Sent measure event")


func _on_ExternalLinkButton_pressed():
	PokiSDK.openExternalLink("https://developers.poki.com/")
	_set_status("Requested external link")
"""
