extends CharacterBody2D
## TODO: Figure out why they can't find eachother
## bat and player are siblings under player1_world
# 
#@onready var shield: Area2D = $"./Player/Shield"
#@onready var player: CharacterBody2D = $"./Player"
# direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
# this shit needs to be lowercased! bullet.tscn
@export var bullet_scene: PackedScene = preload("res://scenes/enemy_bullet.tscn")
@export var bullet_speed: float = 100
@export var shoot_interval: float = 1

@onready var player: CharacterBody2D = get_parent().get_node("player")
@onready var shoot_timer = $ShootTimer
@onready var burst_timer = $BurstTimer
@onready var rotater: Node2D = $Rotater

const BURST_AMOUNT = 3
const BURST_INTERVAL = 0.15
var burst_count = 0

var last_direction = Vector2.RIGHT

var HEALTH = 5
var spiral_angle: float = 0.0
var SPEED = 5.0
#var patterns = ["circle", "fan", "spiral", "line"]
var patterns = ["triple"]
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
	visible = true
	
	# Start the shooting timer
	shoot_timer.wait_time = shoot_interval
	shoot_timer.start()
	
	burst_timer.wait_time = BURST_INTERVAL
	burst_timer.one_shot = false
	burst_timer.timeout.connect(_on_burst_timer_timeout)

	add_to_group("enemy")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.08

func _process(delta):
	const ROTATION_SPEED = 90
	rotater.rotation_degrees = fmod(rotater.rotation_degrees + ROTATION_SPEED * delta, 360)

func _physics_process(delta: float) -> void:
	var direction = (player.global_position-global_position).normalized()
	velocity = velocity.move_toward(direction * SPEED, 200 * delta)
	
	#stop pushing when colliding vertically
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("player"):
			# Remove vertical push if colliding from top/bottom
			if abs(collision.get_normal().y) > 0.7:
				velocity.y = 0
	move_and_slide()
	
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
		"triple":
			_shoot_triple()

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

func _shoot_triple():
	burst_count = 0
	burst_timer.start()
	
func _on_burst_timer_timeout():
	if burst_count == 0:
		last_direction = (player.global_position - global_position).normalized()
	spawn_bullet(last_direction)
	burst_count += 1
	if burst_count >= BURST_AMOUNT:
		burst_timer.stop()
		
func _shoot_line():
	# Shoot straight ahead in a line
	spawn_bullet(Vector2.RIGHT)

func spawn_bullet(dir: Vector2):
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = dir.normalized()
	bullet.speed = bullet_speed
	#bullet.shooter = "enemy" #causing dumb errors

func _on_shoot_timer_timeout():
	shoot_pattern()

func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and body.has_method("player_hit"):
		body.player_hit()

#causing dumb errors
#func _on_area_entered(area: Area2D):
#	if "shooter" in area and area.shooter == "player":
#		bat_hit()
#		area.queue_free()
