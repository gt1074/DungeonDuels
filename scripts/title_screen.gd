extends Control

func _ready() -> void:
	var btn = $VBoxContainer/PlayButton
	if not btn.pressed.is_connected(_on_play_button_pressed):
		btn.pressed.connect(_on_play_button_pressed)

func _unhandled_input(event: InputEvent) -> void:
	# Any joypad button starts the game — no ui_accept mapping needed
	if event is InputEventJoypadButton and event.pressed:
		_on_play_button_pressed()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
