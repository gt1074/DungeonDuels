extends Node

var player_instance: player = null
var world: Node = null
var current_room_node: Node = null
var current_def_index: int = -1
var enemies_remaining: int = 0
var completed_rooms: int = 0

const ROOM_SCENE = preload("res://scenes/rooms/room.tscn")
const NORMAL_ROOM_TYPES = [preload("res://scripts/rooms/room1.gd"), preload("res://scripts/rooms/room2.gd"), preload("res://scripts/rooms/room3.gd")]
const BOSS_ROOM_TYPE = preload("res://scripts/rooms/room_boss.gd")
const BOSS_ROOM_INTERVAL: int = 1

func start(player_node: CharacterBody2D, world_node: Node):
	player_instance = player_node
	world = world_node
	load_random_room()

func load_random_room():
	var definition
	if completed_rooms >= BOSS_ROOM_INTERVAL:
		current_def_index = -1
		definition = BOSS_ROOM_TYPE.new()
	else:
		var available = range(NORMAL_ROOM_TYPES.size()).filter(func(i): return i != current_def_index)
		current_def_index = available[randi() % available.size()]
		definition = NORMAL_ROOM_TYPES[current_def_index].new()

	var room = ROOM_SCENE.instantiate()
	world.add_child(room)

	if current_room_node:
		current_room_node.queue_free()
	current_room_node = room

	room.setup(definition, self )

func register_room(room: Node, spawn_pos: Vector2, enemy_count: int):
	enemies_remaining = enemy_count
	if player_instance.get_parent():
		player_instance.get_parent().remove_child(player_instance)
	player_instance.global_position = spawn_pos
	room.add_child(player_instance)

func on_enemy_died():
	print("Enemy Died! There are ${enemies_remaining} left")
	enemies_remaining -= 1
	if enemies_remaining <= 0:
		if current_def_index == -1:
			completed_rooms = 0
		else:
			completed_rooms += 1
		call_deferred("load_random_room")
