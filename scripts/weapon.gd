extends Node2D
class_name Weapon

@export var fire_rate: float = 0.2

var last_fire_time: float = 0.0
var active: bool = false

func _ready() -> void:
	active = true
	last_fire_time = Time.get_ticks_msec() / 1000.0 - fire_rate

func try_fire(direction: Vector2) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if current_time - last_fire_time >= fire_rate:
		fire(direction)
		last_fire_time = current_time

func fire(_direction: Vector2) -> void:
	pass
