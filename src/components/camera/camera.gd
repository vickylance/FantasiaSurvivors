extends Camera2D


@onready var player: Player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if player != null:
		global_position = player.global_position
	pass
