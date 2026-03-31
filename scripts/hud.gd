extends Control

@export var full_heart: Texture2D
@export var empty_heart: Texture2D

@onready var p1_title_label = $VBoxContainer/P1Center/P1VBox/P1TitleLabel
@onready var p1_hearts = $VBoxContainer/P1Center/P1VBox/P1Hearts
@onready var p1_kills_label = $VBoxContainer/P1Center/P1VBox/P1KillsLabel
@onready var p1_shield_label = $VBoxContainer/P1Center/P1VBox/P1ShieldLabel

@onready var divider_label = $VBoxContainer/DividerCenter/DividerLabel

@onready var p2_title_label = $VBoxContainer/P2Center/P2VBox/P2TitleLabel
@onready var p2_hearts = $VBoxContainer/P2Center/P2VBox/P2Hearts
@onready var p2_kills_label = $VBoxContainer/P2Center/P2VBox/P2KillsLabel
@onready var p2_shield_label = $VBoxContainer/P2Center/P2VBox/P2ShieldLabel

func _process(_delta: float) -> void:
	var p1 = get_node_or_null("/root/game/HBoxContainer/LeftPanel/LeftSubViewportContainer/LeftSubViewport/Player1_World/Player")
	var p1_shield = get_node_or_null("/root/game/HBoxContainer/LeftPanel/LeftSubViewportContainer/LeftSubViewport/Player1_World/Player/Shield")
	
	p1_title_label.text = "P-1"
	divider_label.text = "====="
	p2_title_label.text = "P-2"

	if p1:
		draw_hearts(p1_hearts, p1.HEALTH, 5)
		p1_kills_label.text = "K:" + str(p1.KILLS)
	else:
		draw_hearts(p1_hearts, 0, 5)
		p1_kills_label.text = "K:-"
	
	if p1_shield:
		p1_shield_label.text = "S:" + str(p1_shield.health)
	else:
		p1_shield_label.text = "S:-"

	# temporary fake values for P2
	draw_hearts(p2_hearts, 3, 5)
	p2_kills_label.text = "K:0"
	p2_shield_label.text = "S:0"

func draw_hearts(container: HBoxContainer, health: int, max_health: int) -> void:
	for child in container.get_children():
		child.queue_free()

	for i in range(max_health):
		var heart = TextureRect.new()
		heart.texture = full_heart if i < health else empty_heart
		heart.custom_minimum_size = Vector2(5, 5)
		container.add_child(heart)
