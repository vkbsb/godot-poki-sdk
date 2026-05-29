extends Node


func _enter_tree():
	var version = Engine.get_version_info()
	var major = int(version.get("major", 3))
	var script = null
	var script_path = ""
	if major >= 4:
		script_path = "res://addons/poki-sdk/pokisdk_4.gd"
		script = _load_godot4_script(script_path)
	else:
		script_path = "res://addons/poki-sdk/pokisdk_3.gd"
		script = load(script_path)

	if script == null:
		push_error("Could not load Poki SDK script: " + script_path)
		return

	set_script(script)


func _load_godot4_script(script_path):
	var loader_script = load(script_path)
	if loader_script == null:
		return null

	var loader = loader_script.new()
	if loader == null or not loader.has_method("create_script"):
		return null

	return loader.create_script()
