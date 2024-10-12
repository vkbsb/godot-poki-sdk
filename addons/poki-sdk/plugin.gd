@tool
extends EditorPlugin


func is_poki_added(cfg:ConfigFile):
	var pokiexists = false
	for key in cfg.get_sections():
		if cfg.has_section_key(key, "name"):
			var name:String = cfg.get_value(key, "name")
			if name.begins_with("Poki"):
				pokiexists = true
				break
	return pokiexists
	
func add_poki_export(cfg:ConfigFile):
	var arr = cfg.get_sections()
	var num_exports = len(arr)/2
	var poki_section = "preset" + "." + str(num_exports)
	var poki_options = poki_section + ".options"
	
	#preset.x
	cfg.set_value(poki_section, "name", "Poki")
	cfg.set_value(poki_section, "platform", "Web")
	cfg.set_value(poki_section, "runnable", false)
	cfg.set_value(poki_section, "custom_features", "")
	cfg.set_value(poki_section, "export_filter", "all_resources")
	cfg.set_value(poki_section, "include_filter", "")
	cfg.set_value(poki_section, "exclude_filter", "")
	cfg.set_value(poki_section, "script_export_mode", 2)

	#preset.x.options
	cfg.set_value(poki_options, "html/custom_html_shell", "res://addons/poki-sdk/full-size.html")
	cfg.set_value(poki_options, "html/head_include", """
	<script> 
		//place sitelock code here.
	</script>
	""")
	cfg.set_value(poki_options, "html/focus_canvas_on_start", true)
	cfg.set_value(poki_options, "html/experimental_virtual_keyboard", false)

	
func _enter_tree():
	var cfg = ConfigFile.new()
	cfg.load("res://export_presets.cfg")

	if(self.is_poki_added(cfg)):
		print("Poki export already added")
	else:
		add_poki_export(cfg)
		cfg.save("res://export_presets.cfg")
	
	add_autoload_singleton("PokiSDK", "res://addons/poki-sdk/pokisdk.gd")
	pass


func _exit_tree():
	remove_autoload_singleton("PokiSDK")
	pass
