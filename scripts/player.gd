extends CharacterBody2D

const BULLET = preload("res://scenes/player_bullet.tscn")

var last_aim = Vector2.RIGHT
const FIRE_RATE = 0.5
var fire_timer = 0.0

signal stats_changed(health: int, kills: int)
const SPEED = 75.0
const INVINCIBLE_TIME = 3

var health: int = 5:
	set(value):
		health = value
		stats_changed.emit(health, kills)
var kills: int = 0:
	set(value):
		kills = value
		stats_changed.emit(health, kills)
var invincible: bool = false:
	set = _set_invincible

@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shield: Area2D = $Shield
@onready var aim_indicator: Node2D = $AimIndicator

func _set_invincible(value: bool) -> void:
	if value:
		$InvincibilityTimer.start(INVINCIBLE_TIME)
	invincible = value

func _ready() -> void:
	health = 5
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.08

func _process(delta: float) -> void:
	var aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")

	if aim.length() > 0.2:
		last_aim = aim

	aim_indicator.rotation = last_aim.angle()

	var shield_pressed = Input.is_action_pressed("shield_activate")

	fire_timer -= delta
	if Input.is_action_pressed("shoot") and not shield_pressed and fire_timer <= 0.0:
		fire_timer = FIRE_RATE
		shoot()

	if shield_pressed and not shield.is_broken and not shield.on_cooldown:
		shield.activate()
	else:
		shield.deactivate()

func shoot() -> void:
	var bullet = BULLET.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position + Vector2(0, -8) + last_aim * 10
	bullet.direction = last_aim.normalized()

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var facing = Input.get_axis("move_left", "move_right")
	var animation_state = 0
	if direction != Vector2.ZERO:
		animation_state = 1
		direction = direction.normalized()
		animated_sprite.flip_h = facing < 0
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	if not invincible:
		animated_sprite.play("Running" if animation_state == 1 else "idle")

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("enemy") and collider is CharacterBody2D:
			collider.velocity += velocity * 0.6

func player_hit() -> void:
	if not invincible:
		camera_2d.apply_noise_shake()
		if health > 0:
			health -= 1
			print("Knight got hit, remaining health is ", health)
			animated_sprite.play("Hit")
			invincible = true
		else:
			print("Knight Died!")
			animated_sprite.play("Death")
			invincible = true

func _on_invincibility_timer_timeout() -> void:
	invincible = false
