extends Weapon

@export var bullet_scene: PackedScene
@onready var muzzle: Marker2D = $Muzzle

func _ready() -> void:
	super()
	self.fire_rate = 0.3

func _process(_delta: float) -> void:
	# Always rotate the bow to face the player's current aim direction
	# so the muzzle tip is in the correct world position when firing.
	var player = get_parent().get_parent()  # BowWeapon -> WeaponHolder -> Player
	if player and "last_aim" in player:
		rotation = player.last_aim.angle()

func fire(direction: Vector2) -> void:
	if bullet_scene == null:
		return

	var player = get_parent().get_parent()   # WeaponHolder -> Player
	var world  = player.get_parent()          # Player -> World (inside SubViewport)

	var bullet = bullet_scene.instantiate()
	world.add_child(bullet)

	# muzzle.global_position is correct because the bow is already rotated
	bullet.global_position = muzzle.global_position
	bullet.direction = direction.normalized()
	bullet.shooter = player  # needed so kill credit is awarded on hit
