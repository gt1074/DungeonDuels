extends CharacterBody2D

@onready var camera_2d: Camera2D = $"../Camera2D"

const SPEED = 75.0
var HEALTH = 5
var INVINCIBLE = false:
	set = _set_invincible 
	
const invincible_time = 3

@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shield: Area2D = $Shield

func _set_invincible(value):
	if value: 
		$InvincibilityTimer.start(invincible_time)

	INVINCIBLE = value 

func _ready() -> void:
	HEALTH = 5
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shield_activate"):
		shield.activate()
		
	if Input.is_action_just_released("shield_activate"):
		shield.deactivate()

func _physics_process(delta: float) -> void:
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

func hit() -> void:
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
