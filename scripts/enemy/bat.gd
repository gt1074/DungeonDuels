extends CharacterBody2D

@export var bullet_scene: PackedScene = preload("res://scenes/enemy/enemy_bullet.tscn")
@export var bullet_speed: float = 100
@export var shoot_interval: float = 1
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var player_instance: player = get_parent().get_node("Player")
@onready var shoot_timer = $ShootTimer
@onready var burst_timer = $BurstTimer
@onready var rotater: Node2D = $Rotater

const BURST_AMOUNT = 3
const BURST_INTERVAL = 0.15

var room_manager: Node = null
var _spawn_generation: int = -1

var burst_count = 0
var last_direction = Vector2.RIGHT
var health: int = 5
var spiral_angle: float = 0.0
var speed: float = 5.0
var patterns = ["triple"]
var current_pattern_index = 0

func _flash_hit() -> void:
	animated_sprite.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(self):
		animated_sprite.modulate = Color(1, 1, 1)

func take_damage(amount: int = 1, attacker = null) -> void:
	health -= amount
	if health <= 0:
		if attacker != null and "kills" in attacker:
			attacker.kills += 1
		dies()
		return
	_flash_hit()

func dies():
	if room_manager:
		room_manager.on_enemy_died(_spawn_generation)
	queue_free()

func change_pattern() -> void:
	current_pattern_index = (current_pattern_index + 1) % patterns.size()

func _ready() -> void:
	visible = true
	shoot_timer.wait_time = shoot_interval
	shoot_timer.start()
	burst_timer.wait_time = BURST_INTERVAL
	burst_timer.one_shot = false
	burst_timer.timeout.connect(_on_burst_timer_timeout)
	add_to_group("enemy")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.08
	if room_manager:
		_spawn_generation = room_manager._room_generation

func _process(delta: float) -> void:
	if GameState.is_grace or player_instance.is_dead:
		return
	const ROTATION_SPEED = 90
	rotater.rotation_degrees = fmod(rotater.rotation_degrees + ROTATION_SPEED * delta, 360)

func _physics_process(delta: float) -> void:
	if GameState.is_grace:
		return
	if player_instance.is_dead:
		velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
		move_and_slide()
		return

	var direction = (player_instance.global_position - global_position).normalized()
	velocity = velocity.move_toward(direction * speed, 200 * delta)

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider != null and collider.is_in_group("player"):
			if abs(collision.get_normal().y) > 0.7:
				velocity.y = 0
	move_and_slide()

func shoot_pattern() -> void:
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

func _shoot_circle() -> void:
	var count = 8
	var angle_step = 2 * PI / float(count)
	for i in range(count):
		spawn_bullet(Vector2.RIGHT.rotated(i * angle_step))

func _shoot_fan() -> void:
	var count = 5
	var spread = deg_to_rad(90)
	var step = spread / float(count - 1)
	var start_angle = -spread / 2
	for i in range(count):
		spawn_bullet(Vector2.RIGHT.rotated(start_angle + i * step))

func _shoot_spiral() -> void:
	var count = 6
	var angle_step = 2.0 * PI / float(count)
	for i in range(count):
		spawn_bullet(Vector2.RIGHT.rotated(spiral_angle + i * angle_step))
	spiral_angle += deg_to_rad(15)

func _shoot_triple() -> void:
	burst_count = 0
	burst_timer.start()

func _on_burst_timer_timeout() -> void:
	if burst_count == 0:
		last_direction = (player_instance.global_position - global_position).normalized()
	spawn_bullet(last_direction)
	burst_count += 1
	if burst_count >= BURST_AMOUNT:
		burst_timer.stop()

func _shoot_line() -> void:
	spawn_bullet(Vector2.RIGHT)

func spawn_bullet(dir: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = dir.normalized()
	bullet.speed = bullet_speed

func _on_shoot_timer_timeout() -> void:
	if GameState.is_grace or player_instance.is_dead:
		return
	shoot_pattern()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("player_hit"):
		body.player_hit()

func _on_area_entered(_area: Area2D) -> void:
	pass