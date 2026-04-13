extends Area2D
class_name shield_max_increase

@export var increase_amount = 3

var description = "Increases max shield health"
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var shield: Shield = body.SHIELD
		if shield != null:
			print("Shield is null, why's that huh?")
		else:
			shield.MAX_HEALTH + 3
