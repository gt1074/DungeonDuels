extends Area2D

@export var heal_amount: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("player_hit"):
		# Only heal if not at max
		if body.health < body.MAX_HEALTH:
			body.health = mini(body.health + heal_amount, body.MAX_HEALTH)
			print("Player healed! Health: ", body.health)
			queue_free()
