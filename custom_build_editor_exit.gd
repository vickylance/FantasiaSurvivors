@tool
extends Node
# To be placed in the main scene of the project

func _ready():
	if !OS.has_feature("standalone"): # The Editor
		if "--custom-arg-compile-import" in OS.get_cmdline_args():
			# Force load if necessary
			#var force_load_script: EditorScript= load(...)
			#force_load_script.new()._run()

			# Quit
			Engine.get_main_loop().quit()
