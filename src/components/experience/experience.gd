extends Node
class_name Experience

var experience := 0
var level := 1
var collected_experience := 0
var exp_required := 0

signal level_up()


func _ready() -> void:
	calculate_experience(0)

func calculate_experience(gem_exp: int) -> void:
	exp_required = calculate_experience_cap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required: #level up
		collected_experience -= exp_required - experience
		level += 1
		experience = 0
		exp_required = calculate_experience_cap()
		level_up.emit()
	else:
		experience += collected_experience
		collected_experience = 0
	pass


func calculate_experience_cap() -> int:
	var exp_cap = level
	if level < 25:
		exp_cap = level * 5
	elif level < 40:
		exp_cap = exp_cap + 95 * (level - 19) * 8
	else:
		exp_cap = 255 + (level - 39) * 12
	return exp_cap
