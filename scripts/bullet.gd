extends Area2D

var speed = 200
var direction = Vector2.RIGHT
var shooter = "" # "player" or "enemy"

func _ready():
	monitoring = true

func _process(delta):
	global_position += direction * speed * delta

func _on_kill_timer_timeout():
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if shooter == "enemy":
		if body.is_in_group("player") and body.has_method("player_hit"):
			body.player_hit()
			queue_free()
		elif body.is_in_group("walls"):
			queue_free()

	elif shooter == "player":
		if body.is_in_group("enemy") and body.has_method("bat_hit"):
			body.bat_hit()
			queue_free()
		elif body.is_in_group("walls"):
			queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Only hit shields or specific targets
	if shooter == "enemy" and area.is_in_group("shield"):
		queue_free()
	elif area.is_in_group("walls"):
		queue_free()

	if shooter == "player":
		if area.is_in_group("enemy") and area.has_method("bat_hit"):
			area.bat_hit()
			queue_free()
