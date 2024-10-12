extends Node

var sdk_handle = null
var _cb_commercial_break 
var _cb_reward_break
var _cb_shareable_url

signal commercial_break_done(response) 
signal rewarded_break_done(response)
signal shareable_url_ready(url)

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("web") == false:
		return
		
	sdk_handle = JavaScriptBridge.get_interface("PokiSDK")
	_cb_commercial_break = JavaScriptBridge.create_callback(Callable(self, "on_commercial_break"))
	_cb_reward_break = JavaScriptBridge.create_callback(Callable(self, "on_reward_break"))
	_cb_shareable_url = JavaScriptBridge.create_callback(Callable(self, "on_shareable_url"))

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
	
func on_commercial_break(args):
	print("Commercial break done!")
	emit_signal("commercial_break_done", args[0])

func rewardedBreak():
	if not sdk_handle:
		return
	sdk_handle.rewardedBreak().then(_cb_reward_break)
	
func on_reward_break(args):
	print("Reward break done!")
	emit_signal("rewarded_break_done", args[0])
	
func shareableURL(obj:Dictionary):
	if not sdk_handle:
		return
	var params = JavaScriptBridge.create_object("Object")
	
	for key in obj.keys():
		params[key] = obj[key]
	sdk_handle.shareableURL(params).then(_cb_shareable_url)

func on_shareable_url(url):
	emit_signal("shareable_url_ready", url[0])
	
func isAdBlocked():
	if not sdk_handle:
		return
	var ret = sdk_handle.isAdBlocked()
	return ret
	
func enableEventTracking():
	if not sdk_handle:
		return
	sdk_handle.enableEventTracking()
