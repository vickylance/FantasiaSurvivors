@tool
extends Node

func _ready() -> void:
	if !OS.has_feature("standalone"): # The Editor
		if "--custom-arg-compile-import" in OS.get_cmdline_args():
			# Force load
			var force_load_script: EditorScript = load("res://scan_resources.gd").new() as EditorScript
			force_load_script._run()
			
			Engine.get_main_loop().quit()

