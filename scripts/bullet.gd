extends Area2D
@onready var player: CharacterBody2D = $"../Player"
@onready var shield: Area2D = $"../Player/Shield"

const speed = 100

func _ready():
    monitoring = true
    visible = true

func _process(delta: float) -> void:
    position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_kill_timer_timeout() -> void:
    queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body is CharacterBody2D:
        body.hit()
        queue_free()

func _on_area_entered(area: Area2D) -> void:
    #print("Area entered:", area.name, " groups:", area.get_groups())
    if (area.name == "Shield"):
        queue_free()
