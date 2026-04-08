extends Weapon

@export var bullet_scene: PackedScene
@onready var muzzle: Marker2D = $Muzzle

func _ready() -> void:
	super()
	self.fire_rate = 0.3

func fire(direction: Vector2) -> void:
	if bullet_scene == null or owner_player == null:
		return

	var bullet = bullet_scene.instantiate()
	owner_player.get_parent().add_child(bullet)  # spawn into the World (SubViewport)

	# muzzle.global_position is correct because AimPivot (grandparent) is already rotated
	bullet.global_position = muzzle.global_position
	bullet.direction = direction.normalized()
	bullet.shooter = owner_player
