class_name RoomDefinition
extends Resource

var player_spawn: Vector2 = Vector2(100, 100)
var bat_spawns: Array[Vector2] = []
var slime_spawns: Array[Vector2] = []
var boss_spawns: Array[Vector2] = []
var slime_hard_spawns: Array[Vector2] = []

const BAT_SCENE = preload("res://scenes/enemy/bat.tscn")
const SLIME_SCENE = preload("res://scenes/enemy/slime.tscn")
const BOSS_SCENE = preload("res://scenes/enemy/boss_slime.tscn")
const SLIME_HARD_SCENE = preload("res://scenes/enemy/slime_hard.tscn")

func get_enemy_count() -> int:
	return bat_spawns.size() + slime_spawns.size() + boss_spawns.size() + slime_hard_spawns.size()
 
func spawn_enemies(room: Node, manager: Node):
	print("Manager is: ", manager)
	for pos in bat_spawns:
		var bat = BAT_SCENE.instantiate()
		bat.global_position = pos
		room.add_child(bat)
		bat.room_manager = manager
		bat.connect("tree_exited", Callable(manager, "_on_enemy_removed"))

	for pos in slime_spawns:
		var slime = SLIME_SCENE.instantiate()
		slime.global_position = pos
		room.add_child(slime)
		slime.room_manager = manager
		slime.connect("tree_exited", Callable(manager, "_on_enemy_removed"))

	for pos in boss_spawns:
		var boss = BOSS_SCENE.instantiate()
		boss.global_position = pos
		room.add_child(boss)
		boss.room_manager = manager
		boss.connect("tree_exited", Callable(manager, "_on_enemy_removed"))
		
	for pos in slime_hard_spawns:
		var slime_hard = SLIME_HARD_SCENE.instantiate()
		slime_hard.global_position = pos
		room.add_child(slime_hard)
		slime_hard.room_manager = manager
		slime_hard.connect("tree_exited", Callable(manager, "_on_enemy_removed"))
