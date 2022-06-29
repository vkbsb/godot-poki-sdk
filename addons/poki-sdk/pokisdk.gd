extends Node

var sdk_handle = null
var _cb_commercial_break 
var _cb_reward_break
var _cb_shareable_url

signal commercial_break_done 
signal reward_break_done(response)
signal shareable_url_ready(url)

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("JavaScript") == false:
		return
		
	sdk_handle = JavaScript.get_interface("PokiSDK")
	_cb_commercial_break = JavaScript.create_callback(self, "on_commercial_break")
	_cb_reward_break = JavaScript.create_callback(self, "on_reward_break")
	_cb_shareable_url = JavaScript.create_callback(self, "on_shareable_url")
	
	#create a temp function to handle the idctionary as a parameter for this api.
	#TODO: figure out if there is a better way? 
	JavaScript.eval("""
		PokiSDK.godot_sharable_url = function(params){
			var obj = JSON.parse(params)
			return PokiSDK.shareableURL(obj)
		}
	""", true)

func gameplayStart():
	if not sdk_handle:
		return
	sdk_handle.gameplayStart()
	
func gameplayStop():
	if not sdk_handle:
		return
	sdk_handle.gameplayStop()
	
func commercialBreak():
	if not sdk_handle:
		return
	sdk_handle.commercialBreak().then(_cb_commercial_break)
	
func on_commercial_break():
	print("Commercial break done!")
	emit_signal("commercial_break_done")

func rewardBreak():
	if not sdk_handle:
		return
	sdk_handle.rewardBreak().then(_cb_reward_break)
	
func on_reward_break(success):
	print("Reward break done!")
	emit_signal("reward_break_done", success)
	
func shareableURL(obj:Dictionary):
	if not sdk_handle:
		return
	sdk_handle.godot_sharable_url(JSON.print(obj)).then(_cb_shareable_url)

func on_shareable_url(url):
	emit_signal("shareable_url_ready", url[0])
