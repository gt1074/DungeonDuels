extends Upgrade
class_name attack_rate

@export var speed_increase: int = 0.3

func _ready() -> void:
	self.description = "Increases attack rate"
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var weapon: Node2D = body.current_weapon
		if weapon != null:
			weapon.fire_rate += speed_increase
