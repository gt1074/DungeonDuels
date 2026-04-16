extends Upgrade
class_name speed_boost

const BOOST_AMOUNT: float = 25.0
const MAX_SPEED:    float = 175.0

func _ready() -> void:
	self.description = "Speed\nBoost"
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.speed >= MAX_SPEED:
		return  # Already capped — pickup stays in the world.
	body.speed = minf(body.speed + BOOST_AMOUNT, MAX_SPEED)
	print("Speed boosted to ", body.speed)
	self.on_item_pickup()

func is_available(p: CharacterBody2D) -> bool:
	return p.speed < MAX_SPEED
