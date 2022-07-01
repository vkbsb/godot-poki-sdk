extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	PokiSDK.connect("commercial_break_done", self, "on_commercial_break_done")
	PokiSDK.connect("rewarded_break_done", self, "on_reward_break_done")
	PokiSDK.connect("shareable_url_ready", self, "on_shareable_url_ready")
	pass # Replace with function body.

func on_reward_break_done(success):
	print("Reward response:", success)
	if success:
		$Label.text = "Reward gained!"
	else:
		$Label.text = "No Reward."
	PokiSDK.gameplayStart()
	
func on_commercial_break_done():
	print("Commercial break done")
	PokiSDK.gameplayStart()

func on_shareable_url_ready(url):
	print("URL: ", url)
	$Label.text = url
	
func _on_Button_pressed():
	PokiSDK.gameplayStop()
	PokiSDK.commercialBreak()
	pass # Replace with function body.

func _on_Button2_pressed():
	PokiSDK.shareableURL({"a":1, "b":2})
	pass # Replace with function body.


func _on_Button3_pressed():
	PokiSDK.gameplayStop()
	PokiSDK.rewardedBreak()
	pass # Replace with function body.
