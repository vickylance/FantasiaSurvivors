extends Node

var upgrades: Array[UpgradeItem] = []
@export_global_dir var upgrade_items_path: String


func _ready() -> void:
	load_items(upgrade_items_path + "/")


func load_items(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".remap"):
				file_name = file_name.replace(".remap", "")
			if not dir.current_is_dir():
				upgrades.append(load(path + file_name) as UpgradeItem)
			elif dir.current_is_dir():
				load_items(path + file_name + "/")
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	pass


func get_item(item_name: String) -> UpgradeItem:
	for upgrade_item in upgrades:
		if upgrade_item.name == item_name:
			return upgrade_item
	return null
