extends Area2D
# TODO: Figure out why they can't find eachother
@onready var shield: Area2D = $"./Player/Shield"
@onready var player: CharacterBody2D = $"./Player"

@export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
@export var bullet_speed: float = 200
@export var shoot_interval: float = 0.2

@onready var shoot_timer = $ShootTimer
@onready var rotater: Node2D = $Rotater

var HEALTH = 5
var spiral_angle: float = 0.0

var patterns = ["circle", "fan", "spiral", "line"]
var current_pattern_index = 0

func bat_hit():
	HEALTH -= 1
	print("Bat hit! Remaining health:", HEALTH)
	# Play hit animation if present
	change_pattern()
	if HEALTH <= 0:
		print("Bat died!")
		queue_free()

func change_pattern():
	current_pattern_index = (current_pattern_index + 1) % patterns.size()

func _ready():
	monitoring = true
	visible = true
	
	# Start the shooting timer
	shoot_timer.wait_time = shoot_interval
	shoot_timer.start()

func _process(delta):
	const ROTATION_SPEED = 90
	rotater.rotation_degrees = fmod(rotater.rotation_degrees + ROTATION_SPEED * delta, 360)

func shoot_pattern():
	match patterns[current_pattern_index]:
		"circle":
			_shoot_circle()
		"fan":
			_shoot_fan()
		"spiral":
			_shoot_spiral()
		"line":
			_shoot_line()

func _shoot_circle():
	var count = 8
	var angle_step = 2 * PI / float(count)
	for i in range(count):
		spawn_bullet(Vector2.RIGHT.rotated(i * angle_step))

func _shoot_fan():
	var count = 5
	var spread = deg_to_rad(90)
	var step = spread / float(count - 1)
	var start_angle = -spread / 2
	for i in range(count):
		spawn_bullet(Vector2.RIGHT.rotated(start_angle + i * step))

func _shoot_spiral():
	var count = 6
	var angle_step = 2.0 * PI / float(count)
	for i in range(count):
		spawn_bullet(Vector2.RIGHT.rotated(spiral_angle + i * angle_step))
	spiral_angle += deg_to_rad(15)

func _shoot_line():
	# Shoot straight ahead in a line
	spawn_bullet(Vector2.RIGHT)

func spawn_bullet(dir: Vector2):
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = dir.normalized()
	bullet.speed = bullet_speed
	bullet.shooter = "enemy"

func _on_shoot_timer_timeout():
	shoot_pattern()

func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and body.has_method("hit"):
		body.player_hit()

func _on_area_entered(area: Area2D):
	if area.has_method("bat_hit") and area.shooter == "player":
		area.bat_hit()
		area.queue_free()
