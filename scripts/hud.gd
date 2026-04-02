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

var p1: CharacterBody2D = null
var p1_shield = null

func _ready() -> void:
	p1_title_label.text = "P-1"
	p2_title_label.text = "P-2"
	divider_label.text = "====="

	# Wait one frame for the subviewport scene tree to be ready
	await get_tree().process_frame

	p1 = get_node_or_null("/root/Game/HBoxContainer/LeftPanel/LeftSubViewportContainer/LeftSubViewport/Player1_World/Player")
	p1_shield = get_node_or_null("/root/Game/HBoxContainer/LeftPanel/LeftSubViewportContainer/LeftSubViewport/Player1_World/Player/Shield")

	if p1:
		p1.stats_changed.connect(_on_p1_stats_changed)
		_on_p1_stats_changed(p1.health, p1.kills)
	else:
		draw_hearts(p1_hearts, 0, 5)
		p1_kills_label.text = "K:-"

	if p1_shield:
		p1_shield.shield_changed.connect(_on_p1_shield_changed)
		_on_p1_shield_changed(p1_shield.health)
	else:
		p1_shield_label.text = "S:-"

	# P2 placeholder until P2 is built
	draw_hearts(p2_hearts, 0, 5)
	p2_kills_label.text = "K:-"
	p2_shield_label.text = "S:-"

func _on_p1_stats_changed(health: int, kills: int) -> void:
	draw_hearts(p1_hearts, health, 5)
	p1_kills_label.text = "K:" + str(kills)

func _on_p1_shield_changed(shield_health: int) -> void:
	p1_shield_label.text = "S:" + str(shield_health)

func draw_hearts(container: HBoxContainer, health: int, max_health: int) -> void:
	for child in container.get_children():
		child.queue_free()
	for i in range(max_health):
		var heart = TextureRect.new()
		heart.texture = full_heart if i < health else empty_heart
		heart.custom_minimum_size = Vector2(5, 5)
		container.add_child(heart)
