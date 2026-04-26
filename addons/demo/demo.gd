extends Control

var _pill_shifted := false


func _ready():
	PokiSDK.connect("commercial_break_done", Callable(self, "_on_commercial_break_done"))
	PokiSDK.connect("commercial_break_failed", Callable(self, "_on_commercial_break_failed"))
	PokiSDK.connect("rewarded_break_done", Callable(self, "_on_reward_break_done"))
	PokiSDK.connect("rewarded_break_failed", Callable(self, "_on_reward_break_failed"))
	PokiSDK.connect("shareable_url_ready", Callable(self, "_on_shareable_url_ready"))
	PokiSDK.connect("shareable_url_failed", Callable(self, "_on_shareable_url_failed"))
	PokiSDK.connect("user_ready", Callable(self, "_on_user_ready"))
	PokiSDK.connect("user_failed", Callable(self, "_on_user_failed"))
	PokiSDK.connect("token_ready", Callable(self, "_on_token_ready"))
	PokiSDK.connect("token_failed", Callable(self, "_on_token_failed"))
	PokiSDK.connect("login_done", Callable(self, "_on_login_done"))
	PokiSDK.connect("login_failed", Callable(self, "_on_login_failed"))

	PokiSDK.gameplayStart()
	PokiSDK.movePill(0, 24)
	PokiSDK.measure("demo", "scene", "ready")

	$MarginContainer/PanelContainer/MainColumn/UrlParamLabel.text = "URL param (id): %s" % PokiSDK.getURLParam("id")
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
	$MarginContainer/PanelContainer/MainColumn/ShareUrlLabel.text = "Shareable URL: %s" % url
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


func _set_status(message: String):
	$MarginContainer/PanelContainer/MainColumn/StatusLabel.text = "Status: %s" % message
	print(message)


func _on_CommercialBreakButton_pressed():
	_pause_for_ad()
	PokiSDK.commercialBreak(Callable(self, "_on_ad_started"))


func _on_RewardedBreakButton_pressed():
	_pause_for_ad()
	PokiSDK.rewardedBreak({
		"size": "medium",
		"onStart": Callable(self, "_on_ad_started"),
	})


func _on_ShareableUrlButton_pressed():
	PokiSDK.shareableURL({
		"id": "demo-user",
		"type": "reward",
		"score": 42,
	})


func _on_GetUserButton_pressed():
	PokiSDK.getUser()


func _on_GetTokenButton_pressed():
	PokiSDK.getToken()


func _on_LoginButton_pressed():
	PokiSDK.login()


func _on_MovePillButton_pressed():
	_pill_shifted = not _pill_shifted
	if _pill_shifted:
		PokiSDK.movePill(50, -100)
		_set_status("Moved Poki Pill")
		return

	PokiSDK.movePill(0, 24)
	_set_status("Reset Poki Pill")


func _on_MeasureButton_pressed():
	PokiSDK.measure("demo", "button", "measure")
	_set_status("Sent measure event")


func _on_ExternalLinkButton_pressed():
	PokiSDK.openExternalLink("https://developers.poki.com/")
	_set_status("Requested external link")
