class_name RoomDefinition
extends Resource

var player_spawn: Vector2 = Vector2(100, 100)
var bat_spawns: Array[Vector2] = []
var slime_spawns: Array[Vector2] = []

const BAT_SCENE = preload("res://scenes/bat.tscn")
const SLIME_SCENE = preload("res://scenes/slime.tscn")

func get_enemy_count() -> int:
	return bat_spawns.size() + slime_spawns.size()

func spawn_enemies(room: Node, manager: Node):
	for pos in bat_spawns:
		var bat = BAT_SCENE.instantiate()
		bat.global_position = pos
		bat.died.connect(manager.on_enemy_died)
		room.add_child(bat)

	for pos in slime_spawns:
		var slime = SLIME_SCENE.instantiate()
		slime.global_position = pos
		slime.died.connect(manager.on_enemy_died)
		room.add_child(slime)
