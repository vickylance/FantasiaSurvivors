@tool
extends Node
class_name CreateResJSON

@export var create_res_args: Array[CreateResArgs]
@export var build_json = false


func _process(_delta: float) -> void:
	if build_json:
		create_jsons()
		build_json = false
	pass


func create_jsons() -> void:
	for create_res_arg in create_res_args:
		var json_data: String = JSON.stringify(Utils.build_json_data(create_res_arg.resources_path))
		Utils.save_file(create_res_arg.export_json_path, json_data)
	pass
