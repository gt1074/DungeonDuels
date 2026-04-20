class_name RoomDefinition
extends Resource

var player_spawn: Vector2 = Vector2(100, 100)
var bat_spawns: Array[Vector2] = []
var slime_spawns: Array[Vector2] = []
var boss_spawns: Array[Vector2] = []

const BAT_SCENE = preload("res://scenes/enemy/bat.tscn")
const SLIME_SCENE = preload("res://scenes/enemy/slime.tscn")
const BOSS_SCENE = preload("res://scenes/enemy/boss_slime.tscn")

func get_enemy_count() -> int:
	return bat_spawns.size() + slime_spawns.size() + boss_spawns.size()

func spawn_enemies(room: Node, manager: Node):
	print("Manager is: ", manager)
	for pos in bat_spawns:
		var bat = BAT_SCENE.instantiate()
		bat.global_position = pos
		room.add_child(bat)
		bat.room_manager = manager

	for pos in slime_spawns:
		var slime = SLIME_SCENE.instantiate()
		slime.global_position = pos
		room.add_child(slime)
		slime.room_manager = manager

	for pos in boss_spawns:
		var boss = BOSS_SCENE.instantiate()
		boss.global_position = pos
		room.add_child(boss)
		boss.room_manager = manager
