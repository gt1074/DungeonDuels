class_name Shield
extends Area2D

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var recharge_timer: Timer = $RechargeTimer
@onready var recharge_delay_timer: Timer = $RechargeDelayTimer

var last_aim = Vector2.RIGHT

@export var MAX_HEALTH := 10
@export var cooldown_time := 2.2
@export var recharge_interval := 0.3
@export var recharge_delay := 1.2

var health := 10
var is_broken := false
var on_cooldown := false
var is_active := false

func _ready():
	monitoring = false
	monitorable = false
	visible = false
	collision_polygon.disabled = true
	health = MAX_HEALTH

	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.one_shot = true

	recharge_timer.wait_time = recharge_interval
	recharge_timer.one_shot = false

	recharge_delay_timer.wait_time = recharge_delay
	recharge_delay_timer.one_shot = true

func activate():
	if is_broken or on_cooldown or is_active:
		return

	recharge_timer.stop()
	recharge_delay_timer.stop()

	is_active = true
	monitoring = true
	monitorable = true
	visible = true
	collision_polygon.disabled = false

func deactivate():
	if not is_active:
		return

	is_active = false
	monitoring = false
	monitorable = false
	visible = false
	collision_polygon.disabled = true

	if not is_broken and not on_cooldown and health < MAX_HEALTH:
		recharge_delay_timer.start()

func take_damage(amount: int = 1) -> void:
	if is_broken:
		return

	health -= amount
	print("Shield hit, health:", health)

	if health <= 0:
		break_shield()

func break_shield() -> void:
	is_broken = true
	on_cooldown = true

	recharge_timer.stop()
	recharge_delay_timer.stop()

	deactivate()
	print("Shield broke!")
	cooldown_timer.start()

func _on_cooldown_timer_timeout() -> void:
	health = 1
	is_broken = false
	on_cooldown = false
	print("Shield restored!")

	if not is_active and health < MAX_HEALTH:
		recharge_timer.start()

func _on_recharge_delay_timer_timeout() -> void:
	if not is_active and not is_broken and not on_cooldown and health < MAX_HEALTH:
		recharge_timer.start()

func _on_recharge_timer_timeout() -> void:
	if is_active or is_broken or on_cooldown:
		recharge_timer.stop()
		return

	if health < MAX_HEALTH:
		health += 1
		print("Shield recharged to:", health)
	else:
		recharge_timer.stop()

func _process(_delta):
	if is_active:
		var aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		if aim.length() > 0.2:
			last_aim = aim
		rotation = last_aim.angle()

func _on_area_entered(area):
	pass
