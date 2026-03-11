extends Area2D
@onready var player: CharacterBody2D = $"../Player"
@onready var shield: Area2D = $"../Player/Shield"

const bullet_scene = preload("res://scenes/bullet.tscn")
@onready var shoot_timer = $ShootTimer
@onready var rotater: Node2D = $Rotater

const rotation_speed = 100
const shoot_timer_wait_time = 0.2
const spawn_point_count = 4
const radius = 20

func _ready():
	var step = 2 * PI / spawn_point_count
	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotater.add_child(spawn_point)

	shoot_timer.wait_time = shoot_timer_wait_time
	shoot_timer.start()
	monitoring = true
	visible = true

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.hit()

func _on_area_entered(area: Area2D) -> void:
	#print("Area entered:", area.name, " groups:", area.get_groups())
	if (area.name == "Shield"):
		queue_free()

func _process(delta: float) -> void:
	var new_rotation = rotater.rotation_degrees + rotation_speed * delta
	rotater.rotation_degrees = fmod(new_rotation, 360)

func _on_shoot_timer_timeout() -> void:
	for s: Node2D in rotater.get_children():
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = s.global_position
		bullet.rotation = s.global_rotation
