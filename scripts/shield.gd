extends Area2D

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
var last_aim = Vector2.RIGHT

func _ready():
	monitoring = false
	monitorable = false
	visible = false
	collision_polygon.disabled = true

func activate():
	monitoring = true
	monitorable = true
	visible = true
	collision_polygon.disabled = false

func deactivate():
	monitoring = false
	monitorable = false
	visible = false
	collision_polygon.disabled = true

func _process(_delta):
	if visible:
		var aim = Input.get_vector("aim_left","aim_right","aim_up","aim_down")
		if aim.length() > 0.2:
			last_aim = aim
		rotation = last_aim.angle()

func _on_area_entered(area):
	if area.is_in_group("enemy_bullet"):
		area.queue_free()
