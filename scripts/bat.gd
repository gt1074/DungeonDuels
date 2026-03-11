extends Area2D
@onready var player: CharacterBody2D = $"../Player"
@onready var shield: Area2D = $"../Player/Shield"

func _ready():
	monitoring = true
	visible = true

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.hit()

func _on_area_entered(area: Area2D) -> void:
	print("Area entered:", area.name, " groups:", area.get_groups())
	if (area.name == "Shield"):
		queue_free()
