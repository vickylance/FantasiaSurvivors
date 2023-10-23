@tool
extends EditorPlugin

var plugin = preload("res://addons/generate_res_json/generate_resources_inspector.gd")

func _enter_tree() -> void:
	plugin = plugin.new()
	add_inspector_plugin(plugin)
	pass


func _exit_tree() -> void:
	remove_inspector_plugin(plugin)
	pass
