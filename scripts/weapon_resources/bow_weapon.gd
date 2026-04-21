extends Weapon

@export var bullet_scene: PackedScene
@onready var muzzle: Marker2D = $Muzzle

# ── Bullet mode ───────────────────────────────────────────────────────────────
# Set by BulletUpgrade when the player picks up a bullet modifier.
# Persists for the rest of the run (saved to GameState in game.gd).
var bullet_mode: String = ""   # "", "spread", "bounce", "big", "tracking", "cardinal"

func _ready() -> void:
	super()
	self.fire_rate = 0.3

## Called by BulletUpgrade on pickup.
func set_bullet_mode(mode: String) -> void:
	bullet_mode = mode

func fire(direction: Vector2) -> void:
	if bullet_scene == null or owner_player == null:
		return

	match bullet_mode:
		"spread":
			_fire_spread(direction)
		"cardinal":
			_fire_cardinal()
		_:
			# Default single-bullet modes: "", "bounce", "big", "tracking"
			_spawn_bullet(direction, bullet_mode)

# ── Fire helpers ──────────────────────────────────────────────────────────────

## Single bullet — carries the mode tag so player_bullet.gd can act on it.
func _spawn_bullet(direction: Vector2, mode: String = "") -> void:
	var bullet = bullet_scene.instantiate()
	owner_player.get_parent().add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.direction       = direction.normalized()
	bullet.shooter         = owner_player
	bullet.modulate        = bullet_color
	bullet.apply_mode(mode, owner_player)

## Three-bullet spread fan centred on the aim direction.
func _fire_spread(direction: Vector2) -> void:
	var angles := [-15.0, 0.0, 15.0]
	for deg in angles:
		_spawn_bullet(direction.rotated(deg_to_rad(deg)), "spread")

## Four cardinal bullets regardless of aim direction.
func _fire_cardinal() -> void:
	var dirs := [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	for d in dirs:
		_spawn_bullet(d, "cardinal")