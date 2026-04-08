extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var room_manager: Node = $RoomManager

func _ready():
	room_manager.start(player, self)
