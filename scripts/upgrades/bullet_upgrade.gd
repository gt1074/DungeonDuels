extends Upgrade
class_name BulletUpgrade

## Bullet-modifier upgrade. Set these in each concrete scene / subclass.
@export var bullet_mode: String = ""   # e.g. "spread", "bounce", "big", "tracking", "cardinal"
@export var display_name: String = ""  # short label shown under the pickup

func _ready() -> void:
	self.description = display_name
	body_entered.connect(_on_body_entered)

## Available as long as the player has a bow weapon and doesn't already
## have this exact mode active. All other combinations are allowed.
func is_available(p: CharacterBody2D) -> bool:
	if p.current_weapon == null:
		return false
	if not p.current_weapon.has_method("add_bullet_mode"):
		return false
	# Don't offer the same mode twice
	return not p.current_weapon.has_bullet_mode(bullet_mode)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var weapon = body.current_weapon
	if weapon != null and weapon.has_method("add_bullet_mode"):
		weapon.add_bullet_mode(bullet_mode)
	self.on_item_pickup()