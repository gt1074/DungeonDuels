extends Area2D

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var cooldown_timer: Timer = $CooldownTimer

var last_aim = Vector2.RIGHT

@export var MAX_HEALTH := 10
@export var cooldown_time := 3.0

var health := 10
var is_broken := false
var on_cooldown := false

func _ready():
	monitoring = false
	monitorable = false
	visible = false
	collision_polygon.disabled = true
	health = MAX_HEALTH
	cooldown_timer.wait_time = cooldown_time

func activate():
	if is_broken or on_cooldown:
		return

	monitoring = true
	monitorable = true
	visible = true
	collision_polygon.disabled = false

func deactivate():
	monitoring = false
	monitorable = false
	visible = false
	collision_polygon.disabled = true

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
	deactivate()
	print("Shield broke!")
	cooldown_timer.start()

func _on_cooldown_timer_timeout() -> void:
	health = MAX_HEALTH
	is_broken = false
	on_cooldown = false
	print("Shield restored!")

func _process(_delta):
	if visible:
		var aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		if aim.length() > 0.2:
			last_aim = aim
		rotation = last_aim.angle()

func _on_area_entered(area):
	pass
