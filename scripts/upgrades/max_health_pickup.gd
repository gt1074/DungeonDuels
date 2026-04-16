extends Upgrade
class_name max_health_pickup

## Hard cap: players can never exceed this many hearts.
const MAX_HEARTS: int = 5

func _ready() -> void:
	self.description = "+1 Max Health"
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.max_health >= MAX_HEARTS:
		return  # Already capped — pickup stays in the world.

	body.max_health += 1
	body.health = mini(body.health + 1, body.max_health)
	print("Max health increased to ", body.max_health)
	self.on_item_pickup()
