extends Control

const P1_SPAWN := Vector2(80, 100)
const P2_SPAWN := Vector2(220, 100)

@onready var world: Node2D = $HBoxContainer/BattlePanel/SubViewportContainer/SubViewport/FinalBattleWorld

func _ready() -> void:
	GameState.phase = GameState.Phase.FINAL_BATTLE
	_spawn_players()
	call_deferred("_start_grace")

func _start_grace() -> void:
	GameState.start_grace_period()

func _spawn_players() -> void:
	var player_scene := preload("res://scenes/Player.tscn")

	var p1: CharacterBody2D = player_scene.instantiate()
	p1.action_prefix = ""
	world.add_child(p1)
	p1.position = P1_SPAWN
	p1.max_health = GameState.p1_max_health
	p1.health     = GameState.p1_health
	p1.kills      = GameState.p1_kills

	var p2: CharacterBody2D = player_scene.instantiate()
	p2.action_prefix = "p2_"
	world.add_child(p2)
	p2.position = P2_SPAWN
	p2.max_health = GameState.p2_max_health
	p2.health     = GameState.p2_health
	p2.kills      = GameState.p2_kills
