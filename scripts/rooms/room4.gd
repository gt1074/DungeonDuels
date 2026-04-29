class_name RoomDef4
extends RoomDefinition

func _init():
	player_spawn = Vector2(80, 105)
	bat_spawns = [Vector2(40, 160), Vector2(40, 40)]
	slime_spawns = [Vector2(40, 160), Vector2(40, 105), Vector2(120, 105), 
	Vector2(120, 160)]
	slime_hard_spawns = [Vector2(120, 40)]
	boss_spawns = []
