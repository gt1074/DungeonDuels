extends CharacterBody2D

const BULLET = preload("res://scenes/player_bullet.tscn")

var last_aim = Vector2.RIGHT
const FIRE_RATE = 0.5
var fire_timer = 0.0

@onready var camera_2d: Camera2D = $"../Camera2D"

const SPEED = 75.0
var HEALTH = 5
var INVINCIBLE = false:
	set = _set_invincible 
	
const invincible_time = 3

@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shield: Area2D = $shield

func _set_invincible(value):
	if value: 
		$InvincibilityTimer.start(invincible_time)
	INVINCIBLE = value 

func _ready() -> void:
	HEALTH = 5

	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	safe_margin = 0.08
	
func _process(delta: float) -> void:
	var aim = Input.get_vector("aim_left","aim_right","aim_up","aim_down")
	
	if aim.length() > 0.2:
		last_aim = aim
	
	fire_timer -= delta
	if Input.is_action_pressed("shoot") and fire_timer <= 0.0:
		fire_timer = FIRE_RATE
		shoot()
	
	if Input.is_action_just_pressed("shield_activate"):
		shield.activate()
		
	if Input.is_action_just_released("shield_activate"):
		shield.deactivate()

func shoot():
	var bullet = BULLET.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position + last_aim * 16
	bullet.direction = last_aim.normalized()
	#bullet.shooter = "player"

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var facing = Input.get_axis("move_left", "move_right")
	var animation_state = 0
	if direction != Vector2.ZERO:
		animation_state = 1
		direction = direction.normalized()
		if facing >= 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	if self.INVINCIBLE == false:
		if animation_state == 1:
			animated_sprite.play("Running")
		else:
			animated_sprite.play("idle")
	
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
	
		if collider.is_in_group("enemy"):
			# Push the bat in the direction the player is moving
			if collider is CharacterBody2D:
				collider.velocity += velocity * 0.6

func player_hit() -> void:
	if not INVINCIBLE:
		camera_2d.apply_noise_shake()
		if HEALTH > 0:
			HEALTH = HEALTH - 1
			print("Knight got hit, remaining health is ", HEALTH)
			animated_sprite.play("Hit")
			self.INVINCIBLE = true
		else:
			print("Knight Died!")
			animated_sprite.play("Death")
			self.INVINCIBLE = true

func _on_invincibility_timer_timeout() -> void:
	INVINCIBLE = false
