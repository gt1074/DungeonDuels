extends Upgrade
class_name BulletUpgrade

## Bullet-modifier upgrade.  Set these in each concrete scene / subclass.
@export var bullet_mode: String = ""   # e.g. "spread", "bounce", "big", "tracking", "cardinal"
@export var display_name: String = ""  # short label shown under the pickup

func _ready() -> void:
	self.description = display_name
	body_entered.connect(_on_body_entered)

## A bullet upgrade is available as long as the player has a bow weapon
## and hasn't already got this exact mode equipped.
func is_available(p: CharacterBody2D) -> bool:
	if p.current_weapon == null:
		return false
	if not p.current_weapon.has_method("set_bullet_mode"):
		return false
	# Don't offer the same mode twice
	return p.current_weapon.bullet_mode != bullet_mode

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var weapon = body.current_weapon
	if weapon != null and weapon.has_method("set_bullet_mode"):
		weapon.set_bullet_mode(bullet_mode)
	self.on_item_pickup()