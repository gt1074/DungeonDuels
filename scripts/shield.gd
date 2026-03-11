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

func _process(delta: float) -> void:
	if visible:
		var joy_aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		if joy_aim.length() > 0.2:  # deadzone
			last_aim = joy_aim
		rotation = last_aim.angle()
