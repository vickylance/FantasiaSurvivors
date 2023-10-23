extends Node
class_name Utils

static func save_file(file_path: String, content: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(content)


static func load_file(file_path: String) -> String:
	var file := FileAccess.open(file_path, FileAccess.READ)
	var content := file.get_as_text()
	return content


static func build_json_data(folder_path: String) -> Dictionary:
	var final_json := {}
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".import"): continue
			if file_name.ends_with(".remap"): continue
			if not dir.current_is_dir():
				final_json[file_name] = ProjectSettings.localize_path(folder_path + "/" + file_name)
			elif dir.current_is_dir():
				build_json_data(folder_path + file_name + "/")
			file_name = dir.get_next()
	else:
		print_debug("An error occurred when trying to access the folder_path.")
	return final_json
