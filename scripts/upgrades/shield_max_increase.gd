extends Upgrade
class_name shield_max_increase

@export var increase_amount = 0.5

func _ready() -> void:
	self.description = "Increases max shield health"
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var shield: Shield = body.SHIELD
		if shield != null:
			print("Shield is null, why's that huh?")
		else:
			shield.cooldown_time = shield.cooldown_time
