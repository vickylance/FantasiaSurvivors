@tool
extends Node
class_name CreateResJSON

@export_global_dir var resources_path: String
@export var export_json_path := ""
@export var build_json = false


func _process(_delta: float) -> void:
	if build_json:
		create_json()
		build_json = false
	pass


func create_json() -> void:
	var json_data: String = JSON.stringify(Utils.build_json_data(resources_path))
	Utils.save_file(export_json_path, json_data)
	pass
