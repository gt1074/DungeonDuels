extends CharacterBody2D

@export var bullet_scene: PackedScene = preload("res://scenes/enemy/enemy_bullet.tscn")
@export var bullet_speed: float = 220.0
@export var shoot_interval: float = 0.8

@onready var player_instance: player = get_parent().get_node("Player")
@onready var shoot_timer: Timer = $ShootTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const BURST_AMOUNT = 3
const BURST_INTERVAL = 0.15

var room_manager: Node = null
var burst_count = 0
var last_direction = Vector2.RIGHT
var health: int = 40
var spiral_angle: float = 0.0
var patterns = ["circle", "fan", "spiral"]

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

func dies() -> void:
	if room_manager:
		room_manager.on_enemy_died()
	queue_free()

func _ready() -> void:
	visible = true
	shoot_timer.wait_time = 0.8
	shoot_timer.start()
	add_to_group("enemy")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.08
	animated_sprite.play("idle")

func _process(_delta: float) -> void:
	if GameState.is_grace or player_instance.is_dead:
		return

func _physics_process(_delta: float) -> void:
	if GameState.is_grace:
		return
	if player_instance.is_dead:
		return

func get_pattern() -> String:
	var health_ratio = float(health) / 40.0
	if health_ratio > 0.66:
		return "circle"
	elif health_ratio > 0.33:
		return "fan"
	return "spiral"

func shoot_pattern() -> void:
	match get_pattern():
		"circle":
			_shoot_circle()
		"fan":
			_shoot_fan()
		"spiral":
			_shoot_spiral()

func _shoot_circle() -> void:
	var aim_direction = (player_instance.global_position - global_position).normalized()
	var count = 8
	var angle_step = 2 * PI / float(count)
	for i in range(count):
		spawn_bullet(aim_direction.rotated(i * angle_step))

func _shoot_fan() -> void:
	var aim_direction = (player_instance.global_position - global_position).normalized()
	var count = 5
	var spread = deg_to_rad(90)
	var step = spread / float(count - 1)
	var start_angle = -spread / 2
	for i in range(count):
		spawn_bullet(aim_direction.rotated(start_angle + i * step))

func _shoot_spiral() -> void:
	var aim_direction = (player_instance.global_position - global_position).normalized()
	var count = 6
	var angle_step = 2.0 * PI / float(count)
	for i in range(count):
		spawn_bullet(aim_direction.rotated(spiral_angle + i * angle_step))
	spiral_angle += deg_to_rad(15)

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
