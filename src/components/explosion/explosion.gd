extends Sprite2D


func _ready() -> void:
	$AnimationPlayer.play("explode")
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	pass


func _on_animation_finished(_anim_name: String) -> void:
	queue_free()
	pass
