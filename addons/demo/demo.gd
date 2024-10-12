extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	PokiSDK.connect("commercial_break_done", Callable(self, "on_commercial_break_done"))
	PokiSDK.connect("rewarded_break_done", Callable(self, "on_reward_break_done"))
	PokiSDK.connect("shareable_url_ready", Callable(self, "on_shareable_url_ready"))
	
	$Label3.text = str(PokiSDK.isAdBlocked())
	
	$AudioStreamPlayer.play()
	pass # Replace with function body.

func on_reward_break_done(success):
	print("Reward response:", success)
	if success:
		$Label.text = "Reward gained!"
	else:
		$Label.text = "No Reward."
	PokiSDK.gameplayStart()
	#resume the game audio.
	$AudioStreamPlayer.stream_paused = false
	
func on_commercial_break_done(response):
	print("Commercial break done", response)
	PokiSDK.gameplayStart()
	#resume the game audio
	$AudioStreamPlayer.stream_paused = false

func on_shareable_url_ready(url):
	print("URL: ", url)
	$Label.text = url
	
func _on_Button_pressed():
	#pause any audio running in game. 
	$AudioStreamPlayer.stream_paused = true
	PokiSDK.gameplayStop()
	PokiSDK.commercialBreak()
	pass # Replace with function body.

func _on_Button2_pressed():
	PokiSDK.shareableURL({"a":1, "b":2})
	pass # Replace with function body.


func _on_Button3_pressed():
	#pause any audio running in game. 
	$AudioStreamPlayer.stream_paused = true
	PokiSDK.gameplayStop()
	PokiSDK.rewardedBreak()
	pass # Replace with function body.
