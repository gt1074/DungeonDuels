extends CharacterBody2D

@export var bullet_scene: PackedScene = preload("res://scenes/enemy/enemy_bullet.tscn")
@export var bullet_speed: float = 120.0
@export var shoot_interval: float = 1.5

@onready var player_instance: player = get_parent().get_node("Player")
@onready var shoot_timer: Timer = $ShootTimer
@onready var hop_timer: Timer = $HopTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const HOP_DURATION: float = 0.35   # seconds of active movement per hop
const PAUSE_DURATION: float = 0.4  # seconds of rest between hops
const SPEED: float = 55.0

var room_manager: Node = null

var health: int = 6
var is_hopping: bool = false
var is_shooting: bool = false

func take_damage(amount: int = 1, attacker = null) -> void:
	health -= amount
	if health <= 0:
		if attacker != null:
			attacker.kills += 1
		dies()
		return
	_flash_hit()

func dies():
	if room_manager:
		room_manager.on_enemy_died()
	queue_free()

func _flash_hit() -> void:
	animated_sprite.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(self):
		animated_sprite.modulate = Color(1, 1, 1)

func _ready() -> void:
	add_to_group("enemy")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.08
	shoot_timer.wait_time = shoot_interval
	shoot_timer.start()
	_start_pause()
	animated_sprite.play("idle")

func _start_hop() -> void:
	is_hopping = true
	hop_timer.wait_time = HOP_DURATION
	hop_timer.start()

func _start_pause() -> void:
	is_hopping = false
	hop_timer.wait_time = PAUSE_DURATION
	hop_timer.start()

func _physics_process(delta: float) -> void:
	if GameState.is_grace:
		return
	if player_instance.is_dead:
		velocity = velocity.move_toward(Vector2.ZERO, 300 * delta)
		move_and_slide()
		return

	if is_hopping:
		var direction = (player_instance.global_position - global_position).normalized()
		velocity = velocity.move_toward(direction * SPEED, 300 * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 300 * delta)

	move_and_slide()

func _on_hop_timer_timeout() -> void:
	if is_hopping:
		_start_pause()
	else:
		_start_hop()

func _on_shoot_timer_timeout() -> void:
	if GameState.is_grace or player_instance.is_dead or is_shooting:
		return
	_shoot_with_animation()

func _shoot_with_animation() -> void:
	is_shooting = true
	animated_sprite.play("shoot")
	await animated_sprite.animation_finished
	if not is_instance_valid(self):
		return
	# Hold mouth-open frame so the player can react before the bullet fires
	await get_tree().create_timer(0.45).timeout
	if not is_instance_valid(self):
		return
	# Grace may have started mid-animation (e.g. final battle transition)
	if GameState.is_grace:
		animated_sprite.play("idle")
		is_shooting = false
		return
	var direction = (player_instance.global_position - global_position).normalized()
	spawn_bullet(direction)
	animated_sprite.play("idle")
	is_shooting = false

func spawn_bullet(dir: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = dir.normalized()
	bullet.speed = bullet_speed

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("player_hit"):
		body.player_hit()
