extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var kill_timer: Timer = $KillTimer

var speed: float = 200
var direction: Vector2 = Vector2.RIGHT
var damage: int = 1

func _ready() -> void:
	monitoring = true
	monitorable = true
	print("Bullet ready - monitoring:", monitoring, " monitorable:", monitorable)
	print("Bullet layer:", collision_layer, " mask:", collision_mask)

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	
	# Check for overlapping areas/bodies
	var overlapping_areas = get_overlapping_areas()
	var overlapping_bodies = get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("enemy"):
			print("Bullet detected enemy via overlapping_bodies:", body.name)
			if body.has_method("bat_hit"):
				body.bat_hit(damage)
			queue_free()
			return
	
	for area in overlapping_areas:
		if area.is_in_group("walls"):
			print("Bullet detected wall via overlapping_areas")
			queue_free()
			return

func _on_kill_timer_timeout() -> void:
	print("Bullet expired naturally")
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(get_parent().get_node_or_null("Player"))
		queue_free()
	elif body.is_in_group("walls"):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	print("Bullet area_entered:", area.name, " groups:", area.get_groups())
	if area.is_in_group("walls"):
		queue_free()
	elif area.is_in_group("enemy") and area.has_method("take_damage"):
		area.take_damage()
		queue_free()
