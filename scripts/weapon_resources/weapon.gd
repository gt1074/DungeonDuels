extends Node2D
class_name Weapon
#checking to see if the correct stuff is used for commits
@export var fire_rate: float = 0.2

# Tint applied to every bullet this weapon fires. White = no tint (default).
# Set to a colour in final_battle.gd to distinguish P2's bullets.
var bullet_color: Color = Color.WHITE

var last_fire_time: float = 0.0
var active: bool = false

# Set by the player immediately after equipping this weapon.
# Gives every weapon a direct reference to its owner without
# needing to traverse the scene hierarchy.
var owner_player: CharacterBody2D = null

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
