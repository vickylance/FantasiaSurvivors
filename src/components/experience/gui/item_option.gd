extends ColorRect
class_name ItemOption

var item: UpgradeItem = null
@onready var player: Player = get_tree().get_first_node_in_group("player") as Player
@onready var button: TextureButton = %Button
@onready var level_label: Label = %LabelLevel
@onready var description_label: Label = %LabelDescription
@onready var name_label: Label = %LabelName
@onready var item_icon: TextureRect = %ItemIcon

signal selected_upgrade(upgrade)

func _ready() -> void:
	var res := selected_upgrade.connect(player.upgrade_character) == OK
	assert(res)
	var res1 := button.pressed.connect(click) == OK
	assert(res1)
	
	if item == null:
		item = UpgradeDb.get_item("food")
	
	name_label.text = item.display_name
	item_icon.texture = item.icon
	description_label.text = item.description
	level_label.text = "Level: " + str(item.level)
	pass


func click() -> void:
	selected_upgrade.emit(item)
	pass
