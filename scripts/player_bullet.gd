extends Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var kill_timer: Timer = $KillTimer

var speed = 200
var direction = Vector2.RIGHT

func _ready():
	monitoring = true

func _process(delta):
	global_position += direction * speed * delta

func _on_kill_timer_timeout():
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("bat_hit"):
		body.bat_hit()
		queue_free()
	elif body.is_in_group("walls"):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Only hit shields or specific targets
	if area.is_in_group("walls"):
		queue_free()
	else:
		if area.is_in_group("enemy") and area.has_method("bat_hit"):
			area.bat_hit()
			queue_free()
