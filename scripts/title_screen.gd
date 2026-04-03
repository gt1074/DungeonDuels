extends Control

func _ready() -> void:
	var btn = $VBoxContainer/PlayButton
	if not btn.pressed.is_connected(_on_play_button_pressed):
		btn.pressed.connect(_on_play_button_pressed)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
