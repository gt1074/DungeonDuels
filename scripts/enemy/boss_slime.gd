extends CharacterBody2D
class_name BossSlime

@export var bullet_scene: PackedScene = preload("res://scenes/enemy/enemy_bullet.tscn")
@export var bullet_speed: float = 100.0

@onready var player_instance: player = get_parent().get_node("Player")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hop_timer: Timer = $HopTimer
@onready var shoot_timer: Timer = $ShootTimer

const MAX_HEALTH: int  = 20

const P1_SPEED: float           = 35.0
const P1_HOP_DURATION: float    = 0.5
const P1_PAUSE_DURATION: float  = 0.9
const P1_SHOOT_INTERVAL: float  = 2.2

const P2_SPEED: float           = 100.0
const P2_HOP_DURATION: float    = 0.45
const P2_PAUSE_DURATION: float  = 0.55
const P2_SHOOT_INTERVAL: float  = 1.6
const ENRAGED_TINT := Color(1.0, 0.45, 0.45)

const TELEGRAPH_TIME: float    = 0.5
const RING_BULLET_COUNT: int   = 8

const BURST_AMOUNT: int        = 3
const BURST_INTERVAL: float    = 0.15

# Animation names as they exist in boss_slime.tscn
const ANIM_IDLE  := &"new_animation"
const ANIM_SHOOT := &"new_animation_1"

var room_manager: Node = null
var health: int = MAX_HEALTH
var is_hopping: bool = false
var is_shooting: bool = false
var is_enraged: bool = false

func _flash_hit() -> void:
	animated_sprite.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(self):
		animated_sprite.modulate = ENRAGED_TINT if is_enraged else Color.WHITE

func take_damage(amount: int = 1, attacker = null) -> void:
	health -= amount
	if health <= 0:
		if attacker != null and "kills" in attacker:
			attacker.kills += 1
		dies()
		return
	if not is_enraged and health <= MAX_HEALTH / 2:
		_enter_phase_2()
	_flash_hit()

func dies() -> void:
	if room_manager:
		room_manager.on_enemy_died()
	queue_free()

func _enter_phase_2() -> void:
	is_enraged = true
	animated_sprite.modulate = ENRAGED_TINT
	shoot_timer.wait_time = P2_SHOOT_INTERVAL
	if player_instance and player_instance.camera_2d:
		player_instance.camera_2d.apply_noise_shake()

func _ready() -> void:
	add_to_group("enemy")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.08
	scale = Vector2(2.0, 2.0)

	animated_sprite.play(ANIM_IDLE)

	shoot_timer.wait_time = P1_SHOOT_INTERVAL
	shoot_timer.start()

	_start_pause()

func _current_speed() -> float:
	return P2_SPEED if is_enraged else P1_SPEED

func _start_hop() -> void:
	is_hopping = true
	hop_timer.wait_time = P2_HOP_DURATION if is_enraged else P1_HOP_DURATION
	hop_timer.start()

func _start_pause() -> void:
	is_hopping = false
	hop_timer.wait_time = P2_PAUSE_DURATION if is_enraged else P1_PAUSE_DURATION
	hop_timer.start()

func _physics_process(delta: float) -> void:
	if GameState.is_grace:
		return
	if player_instance.is_dead:
		velocity = velocity.move_toward(Vector2.ZERO, 300 * delta)
		move_and_slide()
		return

	if is_hopping and not is_shooting:
		var direction = (player_instance.global_position - global_position).normalized()
		velocity = velocity.move_toward(direction * _current_speed(), 250 * delta)
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
	if is_enraged:
		_attack_triple()
	else:
		_attack_ring()

func _attack_ring() -> void:
	is_shooting = true
	for i in 3:
		if not is_instance_valid(self):
			return
		animated_sprite.modulate = Color(1.6, 1.6, 1.6)
		await get_tree().create_timer(TELEGRAPH_TIME / 6.0).timeout
		if not is_instance_valid(self):
			return
		animated_sprite.modulate = ENRAGED_TINT if is_enraged else Color.WHITE
		await get_tree().create_timer(TELEGRAPH_TIME / 6.0).timeout

	if not is_instance_valid(self) or GameState.is_grace:
		is_shooting = false
		return

	var angle_step: float = TAU / float(RING_BULLET_COUNT)
	for i in range(RING_BULLET_COUNT):
		spawn_bullet(Vector2.RIGHT.rotated(i * angle_step))

	is_shooting = false

func _attack_triple() -> void:
	is_shooting = true
	var locked_direction := (player_instance.global_position - global_position).normalized()
	for i in range(BURST_AMOUNT):
		if not is_instance_valid(self):
			return
		if GameState.is_grace or player_instance.is_dead:
			is_shooting = false
			return
		spawn_bullet(locked_direction)
		if i < BURST_AMOUNT - 1:
			await get_tree().create_timer(BURST_INTERVAL).timeout
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
