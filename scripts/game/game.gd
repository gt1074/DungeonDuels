extends Control

@onready var p1_opponent_ticker: Label = $HBoxContainer/LeftPanel/LeftSubViewportContainer/P1OpponentTicker
@onready var p2_opponent_ticker: Label = $HBoxContainer/RightPanel/RightSubViewportContainer/P2OpponentTicker

func _ready() -> void:
	# Always reset to DUNGEON so a rematch from the title screen starts clean.
	GameState.phase = GameState.Phase.DUNGEON
	MusicManager.play_game_music()
	var overlay := preload("res://scripts/ui/grace_overlay.gd").new()
	add_child(overlay)
	GameState.start_match_timer()
	GameState.start_grace_period()
	GameState.timer_expired.connect(_on_timer_expired, CONNECT_ONE_SHOT)

	# Opponent ticker — overlays the top of each player's viewport
	p1_opponent_ticker.modulate.a = 0.0
	p2_opponent_ticker.modulate.a = 0.0
	GameState.opponent_event.connect(_on_opponent_event)

func _process(delta: float) -> void:
	GameState.tick(delta)

# ── Timer expired → transition to Final Battle ────────────────────────────────

func _on_timer_expired() -> void:
	# Snapshot player stats so the final battle can restore them
	var players = get_tree().get_nodes_in_group("player")
	var p1: CharacterBody2D = null
	var p2: CharacterBody2D = null
	for p in players:
		if p.action_prefix == "":
			p1 = p
		elif p.action_prefix == "p2_":
			p2 = p
	if p1 and p2:
		GameState.save_player_stats(p1, p2)

	get_tree().change_scene_to_file("res://scenes/game/final_battle.tscn")

# ── Opponent ticker ───────────────────────────────────────────────────────────

func _on_opponent_event(from_prefix: String, message: String) -> void:
	# Show the message on the OPPOSITE player's screen.
	if from_prefix == "":
		_flash_ticker(p2_opponent_ticker, message)
	else:
		_flash_ticker(p1_opponent_ticker, message)

func _flash_ticker(label: Label, message: String) -> void:
	label.text = message
	if label.has_meta("tween"):
		var prev: Tween = label.get_meta("tween")
		if prev and prev.is_valid():
			prev.kill()
	var tw := create_tween()
	label.set_meta("tween", tw)
	tw.tween_property(label, "modulate:a", 1.0, 0.15)
	tw.tween_interval(2.0)
	tw.tween_property(label, "modulate:a", 0.0, 0.4)
