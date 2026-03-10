extends Area2D

func _ready():
	monitoring = false
	visible = false

func activate():
	visible = true
	monitoring = true

func deactivate():
	visible = false
	monitoring = false

func _process(delta: float) -> void:
	if visible:
		look_at(get_global_mouse_position())
