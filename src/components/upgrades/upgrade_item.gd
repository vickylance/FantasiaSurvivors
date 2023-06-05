extends Resource
class_name UpgradeItem

@export var name: String
@export var icon: Texture
@export var display_name: String
@export_multiline var description: String
@export var level: int = 1
@export var prerequisite: Array[UpgradeItem] = []
@export_enum("Weapon", "Food") var type := "Weapon"
