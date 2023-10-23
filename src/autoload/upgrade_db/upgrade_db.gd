extends Node

var upgrades: Array[UpgradeItem] = []
@export_file("*.json") var json_path = ""


func _ready() -> void:
	load_items()


func load_items() -> void:
	var json_string: String = Utils.load_file(json_path)
	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		return
	var data_received: Dictionary = json.data
	if typeof(data_received) == TYPE_DICTIONARY:
		for key in data_received.keys():
			var upgrade_item_path := data_received[key] as String
			var upgrade_item: UpgradeItem = load(upgrade_item_path) as UpgradeItem
			upgrades.append(upgrade_item)


func get_item(item_name: String) -> UpgradeItem:
	for upgrade_item in upgrades:
		if upgrade_item.name == item_name:
			return upgrade_item
	return null

