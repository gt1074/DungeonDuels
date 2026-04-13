extends Area2D

@export var weapon_scene: PackedScene

func _on_body_entered(body: Node) -> void:
	if body.has_method("equip_weapon"):
		call_deferred("_give_weapon", body)

func _give_weapon(body: Node) -> void:
	if weapon_scene == null:
		return

	body.equip_weapon(weapon_scene)
	queue_free()
