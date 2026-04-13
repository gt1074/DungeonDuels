extends Node2D

func setup(definition: RoomDefinition, manager: Node):
	manager.register_room(self, definition.player_spawn, definition.get_enemy_count())
	definition.spawn_enemies(self, manager)
