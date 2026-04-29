extends Control

const P1_SPAWN := Vector2(80, 100)
const P2_SPAWN := Vector2(220, 100)

@onready var world: Node2D = $HBoxContainer/BattlePanel/SubViewportContainer/SubViewport/FinalBattleWorld
@onready var _hud: Control  = $HBoxContainer/CenterPanel/HUD

var _p1: CharacterBody2D = null
var _p2: CharacterBody2D = null

var _game_over: bool = false

func _ready() -> void:
	GameState.phase = GameState.Phase.FINAL_BATTLE
	_hud.hide_timer()
	_spawn_players()
	var overlay := preload("res://scripts/ui/grace_overlay.gd").new()
	add_child(overlay)
	call_deferred("_start_grace")

func _start_grace() -> void:
	GameState.start_grace_period()

func _spawn_players() -> void:
	var player_scene := preload("res://scenes/player/Player.tscn")

	_p1 = player_scene.instantiate()
	_p1.action_prefix = ""
	world.add_child(_p1)
	_p1.position   = P1_SPAWN
	_p1.max_health = GameState.p1_max_health
	_p1.health     = GameState.p1_max_health
	_p1.kills      = GameState.p1_kills
	_p1.eliminated.connect(_on_player_eliminated.bind(_p1))

	_p2 = player_scene.instantiate()
	_p2.action_prefix = "p2_"
	world.add_child(_p2)
	_p2.position   = P2_SPAWN
	_p2.max_health = GameState.p2_max_health
	_p2.health     = GameState.p2_max_health
	_p2.kills      = GameState.p2_kills
	_p2.eliminated.connect(_on_player_eliminated.bind(_p2))

	# Wait one frame for equip_weapon (async) to finish.
	await get_tree().process_frame

	# Restore weapon stats — fire rate, bullet colour, and bullet modes.
	_p1.current_weapon.fire_rate = GameState.p1_fire_rate
	_p1.speed                    = GameState.p1_speed
	if _p1.current_weapon.has_method("add_bullet_mode"):
		for mode in GameState.p1_bullet_modes:
			_p1.current_weapon.add_bullet_mode(mode)

	_p2.current_weapon.fire_rate    = GameState.p2_fire_rate
	_p2.current_weapon.bullet_color = Color(1.0, 0.25, 0.25)
	_p2.speed                       = GameState.p2_speed
	if _p2.current_weapon.has_method("add_bullet_mode"):
		for mode in GameState.p2_bullet_modes:
			_p2.current_weapon.add_bullet_mode(mode)

	# Restore shield stats.
	var s1: Shield = _p1.get_node("Shield")
	s1.apply_stats(
		GameState.p1_shield_max_health,
		GameState.p1_shield_cooldown_time,
		GameState.p1_shield_recharge_interval,
		GameState.p1_shield_recharge_delay
	)

	var s2: Shield = _p2.get_node("Shield")
	s2.apply_stats(
		GameState.p2_shield_max_health,
		GameState.p2_shield_cooldown_time,
		GameState.p2_shield_recharge_interval,
		GameState.p2_shield_recharge_delay
	)

func _on_player_eliminated(loser: CharacterBody2D) -> void:
	_game_over = true
	var winner_label := "P2 Wins!" if loser.action_prefix == "" else "P1 Wins!"
	_show_winner(winner_label)

func _show_winner(text: String) -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.0, 0.0, 0.6)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color.WHITE)
	add_child(label)

	var hint := Label.new()
	hint.text = "Press  Y / △  to return to menu"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.vertical_alignment   = VERTICAL_ALIGNMENT_BOTTOM
	hint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hint.offset_bottom = -8
	hint.add_theme_font_size_override("font_size", 10)
	hint.add_theme_color_override("font_color", Color(1.0, 1.0, 0.5, 1.0))
	add_child(hint)

func _unhandled_input(event: InputEvent) -> void:
	if not _game_over:
		return
	var pressed_y: bool = (
		event is InputEventJoypadButton
		and event.pressed
		and event.button_index == JOY_BUTTON_Y
	)
	var pressed_esc: bool = (
		event is InputEventKey
		and event.pressed
		and event.keycode == KEY_ESCAPE
	)
	if pressed_y or pressed_esc:
		get_tree().change_scene_to_file("res://scenes/ui/title_screen.tscn")