extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var kill_timer: Timer = $KillTimer

var speed: float = 200
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	monitoring = true

func _process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_kill_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(get_parent().get_node_or_null("Player"))
		queue_free()
	elif body.is_in_group("walls"):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("walls"):
		queue_free()
	elif area.is_in_group("enemy") and area.has_method("take_damage"):
		area.take_damage()
		queue_free()
