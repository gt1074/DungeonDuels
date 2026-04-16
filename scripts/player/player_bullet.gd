extends Area2D

@onready var kill_timer: Timer = $KillTimer

var speed: float = 200
var direction: Vector2 = Vector2.RIGHT
var damage: int = 1
var shooter = null  # Set by the weapon when spawning; used to award kill credit

func _ready() -> void:
	monitoring = true
	monitorable = true

func _process(delta: float) -> void:
	global_position += direction * speed * delta

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
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("shield") and area.is_active:
		if area.get_parent() == shooter:
			return
		area.take_damage(damage)
		queue_free()
		return
	if area.is_in_group("walls"):
		queue_free()
