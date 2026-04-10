extends Control

const P1_SPAWN := Vector2(80, 100)
const P2_SPAWN := Vector2(220, 100)

@onready var world: Node2D = $HBoxContainer/BattlePanel/SubViewportContainer/SubViewport/FinalBattleWorld

var _p1: CharacterBody2D = null
var _p2: CharacterBody2D = null

func _ready() -> void:
	GameState.phase = GameState.Phase.FINAL_BATTLE
	_spawn_players()
	call_deferred("_start_grace")

func _start_grace() -> void:
	GameState.start_grace_period()

func _spawn_players() -> void:
	var player_scene := preload("res://scenes/Player.tscn")

	_p1 = player_scene.instantiate()
	_p1.action_prefix = ""
	world.add_child(_p1)
	_p1.position = P1_SPAWN
	_p1.max_health = GameState.p1_max_health
	_p1.health     = GameState.p1_health
	_p1.kills      = GameState.p1_kills
	_p1.eliminated.connect(_on_player_eliminated.bind(_p1))

	_p2 = player_scene.instantiate()
	_p2.action_prefix = "p2_"
	world.add_child(_p2)
	_p2.position = P2_SPAWN
	_p2.max_health = GameState.p2_max_health
	_p2.health     = GameState.p2_health
	_p2.kills      = GameState.p2_kills
	_p2.eliminated.connect(_on_player_eliminated.bind(_p2))

# Called when a player fires their 'eliminated' signal.
# The loser's action_prefix tells us which player won.
func _on_player_eliminated(loser: CharacterBody2D) -> void:
	var winner_label := "P2 Wins!" if loser.action_prefix == "" else "P1 Wins!"
	_show_winner(winner_label)

func _show_winner(text: String) -> void:
	# Semi-transparent dark backdrop over the whole scene.
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.0, 0.0, 0.6)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	# Winner announcement label centred on screen.
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color.WHITE)
	add_child(label)
