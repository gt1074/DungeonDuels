extends Weapon

@export var bullet_scene: PackedScene
@onready var muzzle: Marker2D = $Muzzle

func _ready() -> void:
	super ()
	self.fire_rate = 0.3

func fire(direction: Vector2) -> void:
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = muzzle.global_position
	bullet.direction = direction.normalized()
