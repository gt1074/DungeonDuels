extends Area2D

@onready var kill_timer: Timer = $KillTimer
@onready var sprite: Sprite2D = $Sprite2D

var speed: float        = 200
var direction: Vector2  = Vector2.RIGHT
var damage: int         = 1
var shooter             = null   # Set by the weapon; used for kill credit.

# ── Bullet mode state ─────────────────────────────────────────────────────────
var _mode: String        = ""
var bounces_left: int    = 0
var _tracking_target     = null   # CharacterBody2D reference for tracking mode

## Called by bow_weapon immediately after spawning.
## Must be called BEFORE the bullet enters _process.
func apply_mode(mode: String, owning_player) -> void:
	_mode = mode
	match mode:
		"bounce":
			bounces_left = 3
		"big":
			scale    = Vector2(2.2, 2.2)
			damage   = 2
		"tracking":
			_find_nearest_enemy(owning_player)
		_:
			pass   # "", "spread", "cardinal" — no extra setup needed

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	monitoring  = true
	monitorable = true

func _process(delta: float) -> void:
	# Tracking: steer toward the nearest enemy each frame.
	if _mode == "tracking" and is_instance_valid(_tracking_target):
		var desired = (_tracking_target.global_position - global_position).normalized()
		# Gradually rotate toward the target — not instant, so it can be dodged.
		direction = direction.lerp(desired, 6.0 * delta).normalized()

	global_position += direction * speed * delta

# ── Collision ─────────────────────────────────────────────────────────────────

func _on_kill_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return

	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(damage, shooter)
		queue_free()

	elif GameState.phase == GameState.Phase.FINAL_BATTLE \
			and body.is_in_group("player") \
			and body.has_method("player_hit"):
		body.player_hit(shooter)
		queue_free()

	elif body.is_in_group("walls"):
		_handle_wall_hit()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("shield") and area.is_active:
		if area.get_parent() == shooter:
			return
		area.take_damage(damage)
		queue_free()
		return
	if area.is_in_group("walls"):
		_handle_wall_hit()

# ── Helpers ───────────────────────────────────────────────────────────────────

## Reflect off walls if bounces remain; otherwise destroy.
func _handle_wall_hit() -> void:
	if _mode == "bounce" and bounces_left > 0:
		bounces_left -= 1
		# Determine which axis to reflect on by checking the wall normal.
		# We cast a short ray in the direction of travel to find the surface.
		var space  = get_world_2d().direct_space_state
		var params = PhysicsRayQueryParameters2D.create(
			global_position,
			global_position + direction * 8.0,
			2   # walls collision layer
		)
		var result = space.intersect_ray(params)
		if result:
			var normal: Vector2 = result["normal"]
			direction = direction.bounce(normal)
		else:
			# Fallback: flip the dominant axis
			if abs(direction.x) > abs(direction.y):
				direction.x *= -1
			else:
				direction.y *= -1
	else:
		queue_free()

## Find the nearest target to home toward.
## In the dungeon: nearest "enemy"-group node.
## In the final battle: nearest "player"-group node that isn't the shooter.
func _find_nearest_enemy(owning_player) -> void:
	var best_dist := INF
	var best_node = null

	var candidates: Array = []
	if GameState.phase == GameState.Phase.FINAL_BATTLE:
		for p in get_tree().get_nodes_in_group("player"):
			if p != owning_player:
				candidates.append(p)
	else:
		candidates = get_tree().get_nodes_in_group("enemy")

	for target in candidates:
		if not is_instance_valid(target):
			continue
		var d = global_position.distance_squared_to(target.global_position)
		if d < best_dist:
			best_dist = d
			best_node = target
	_tracking_target = best_node