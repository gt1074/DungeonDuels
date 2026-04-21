extends Node

var player_instance: player = null
var world: Node = null
var current_room_node: Node = null
var current_def_index: int = -1
var enemies_remaining: int = 0
var upgrade_1: Upgrade = null
var upgrade_2: Upgrade = null
var upgrade_3: Upgrade = null   # bullet upgrade — only present after a boss room
var loading: bool = false

# Tracks how many rooms have been completed so far (incremented on clear).
# The NEXT room to load is a boss room when rooms_completed % 3 == 2 (0-based).
# i.e. room sequence: normal(0), normal(1), boss(2), normal(3), normal(4), boss(5) …
var rooms_completed: int = 0

const ROOM_SCENE = preload("res://scenes/rooms/room.tscn")
const BulletUpgradeScript = preload("res://scripts/upgrades/bullet_upgrade.gd")

# ── Room type pools ───────────────────────────────────────────────────────────
var NORMAL_ROOM_TYPES: Array = [RoomDef2, RoomDef3]
var BOSS_ROOM_TYPE = RoomDef1

# ── Stat upgrade pool ─────────────────────────────────────────────────────────
const UPGRADE_SCENES = [
	preload("res://scenes/upgrades/attack_rate.tscn"),
	preload("res://scenes/upgrades/speed_boost.tscn"),
	preload("res://scenes/upgrades/health_max.tscn"),
	preload("res://scenes/upgrades/shield_regen.tscn"),
	preload("res://scenes/upgrades/shield_max.tscn"),
]

# ── Bullet upgrade pool ───────────────────────────────────────────────────────
const BULLET_MODES: Array = [
	["spread",   "Spread Shot"],
	["bounce",   "Bouncing Bullets"],
	["big",      "Big Bullets"],
	["tracking", "Tracking Bullets"],
	["cardinal", "Cardinal Shot"],
]

# ── Public API ────────────────────────────────────────────────────────────────

func start(player_node: CharacterBody2D, world_node: Node) -> void:
	player_instance = player_node
	world = world_node
	_load_next_room()

func on_upgrade_pickup(picked_upgrade: Upgrade) -> void:
	print("Item picked up")
	for u: Upgrade in [upgrade_1, upgrade_2, upgrade_3]:
		if u != picked_upgrade and is_instance_valid(u):
			u.queue_free()
	upgrade_1 = null
	upgrade_2 = null
	upgrade_3 = null
	_load_next_room.call_deferred()

func on_enemy_died() -> void:
	enemies_remaining -= 1
	print("Enemy died! %d remaining" % enemies_remaining)
	if enemies_remaining <= 0 and not loading:
		loading = true
		await get_tree().create_timer(1.0).timeout

		# Was the room we just cleared a boss room?
		var was_boss: bool = (rooms_completed % 3 == 2)
		rooms_completed += 1

		_spawn_stat_upgrades()
		if was_boss:
			print("Boss cleared — also spawning bullet upgrade")
			_spawn_bullet_upgrade()

		loading = false

func register_room(room: Node, spawn_pos: Vector2, enemy_count: int) -> void:
	enemies_remaining = enemy_count
	if player_instance.get_parent():
		player_instance.get_parent().remove_child(player_instance)
	player_instance.global_position = spawn_pos
	room.add_child(player_instance)

# ── Room loading ──────────────────────────────────────────────────────────────

func _load_next_room() -> void:
	# rooms_completed is already incremented, so it reflects how many are done.
	# The room we're about to load sits at index rooms_completed (0-based).
	var is_boss: bool = (rooms_completed % 3 == 2)
	_load_room(is_boss)

func _load_room(is_boss: bool) -> void:
	var room: Node = ROOM_SCENE.instantiate()
	world.add_child(room)

	if current_room_node:
		current_room_node.queue_free()
	current_room_node = room

	var definition: RoomDefinition
	if is_boss:
		definition = BOSS_ROOM_TYPE.new()
		print("Loading boss room")
	else:
		var last_type: Object = _last_normal_type()
		var available: Array = NORMAL_ROOM_TYPES.filter(
			func(t: Object) -> bool: return t != last_type
		)
		var chosen_type: Object = available[randi() % available.size()]
		current_def_index = NORMAL_ROOM_TYPES.find(chosen_type)
		definition = chosen_type.new()
		print("Loading normal room")

	room.setup(definition, self)

func _last_normal_type() -> Object:
	if current_def_index < 0 or current_def_index >= NORMAL_ROOM_TYPES.size():
		return null
	return NORMAL_ROOM_TYPES[current_def_index]

# ── Stat upgrades (spawned after every room clear) ────────────────────────────

func _spawn_stat_upgrades() -> void:
	var label_1: Label = current_room_node.get_node("CanvasLayer/Upgrade1_label")
	var label_2: Label = current_room_node.get_node("CanvasLayer/Upgrade2_label")

	var stat_pool: Array[Upgrade] = []
	for scene: PackedScene in UPGRADE_SCENES:
		var candidate := scene.instantiate() as Upgrade
		if candidate.is_available(player_instance):
			stat_pool.append(candidate)
		else:
			candidate.free()

	if stat_pool.size() < 2:
		push_warning("RoomManager: fewer than 2 stat upgrades available — pool size: %d" % stat_pool.size())

	stat_pool.shuffle()

	upgrade_1 = stat_pool[0]
	upgrade_1.position     = Vector2(50, 50)
	upgrade_1.room_manager = self

	upgrade_2 = stat_pool[1]
	upgrade_2.position     = Vector2(110, 50)
	upgrade_2.room_manager = self

	for i in range(2, stat_pool.size()):
		stat_pool[i].free()

	current_room_node.add_child(upgrade_1)
	current_room_node.add_child(upgrade_2)
	label_1.text = upgrade_1.description
	label_2.text = upgrade_2.description

# ── Bullet upgrade (spawned only after a boss room clear) ─────────────────────

func _spawn_bullet_upgrade() -> void:
	var current_mode: String = ""
	if player_instance.current_weapon != null and "bullet_mode" in player_instance.current_weapon:
		current_mode = player_instance.current_weapon.bullet_mode

	var bullet_pool: Array = BULLET_MODES.filter(
		func(entry: Array) -> bool: return entry[0] != current_mode
	)
	bullet_pool.shuffle()
	var chosen: Array = bullet_pool[0]

	upgrade_3 = _make_bullet_upgrade(chosen[0], chosen[1])
	# Place at the bottom-centre of the room world space.
	# The room viewport is 160×202; bottom area is around y=155.
	upgrade_3.position     = Vector2(80, 155)
	upgrade_3.room_manager = self
	current_room_node.add_child(upgrade_3)

	# Build a label for it on the CanvasLayer so it matches the stat upgrade labels.
	_add_bullet_upgrade_label(chosen[1])

func _add_bullet_upgrade_label(text: String) -> void:
	var canvas: CanvasLayer = current_room_node.get_node("CanvasLayer")

	# Re-use the same font the other labels use if it's accessible; otherwise
	# the default font is fine — Label renders without a custom font too.
	var font_ref: FontFile = null
	var existing: Label = current_room_node.get_node_or_null("CanvasLayer/Upgrade1_label")
	if existing:
		font_ref = existing.get_theme_font("font") as FontFile

	var lbl := Label.new()
	lbl.name = "Upgrade3_label"
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Position the label just above the pickup (pickup is at world y≈155,
	# CanvasLayer coordinates match screen pixels at the default zoom).
	lbl.offset_left   = 64.0
	lbl.offset_top    = 158.0
	lbl.offset_right  = 116.0
	lbl.offset_bottom = 178.0
	lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))   # gold
	lbl.add_theme_font_size_override("font_size", 9)
	if font_ref:
		lbl.add_theme_font_override("font", font_ref)
	canvas.add_child(lbl)

# ── Bullet upgrade factory ────────────────────────────────────────────────────

func _make_bullet_upgrade(mode: String, label: String) -> Upgrade:
	var u: Upgrade = BulletUpgradeScript.new()
	u.set("bullet_mode", mode)
	u.set("display_name", label)
	u.description  = label

	var shape_node := CollisionShape2D.new()
	var circle     := CircleShape2D.new()
	circle.radius  = 6.0
	shape_node.shape = circle
	u.add_child(shape_node)

	var sprite     := Sprite2D.new()
	sprite.texture  = _diamond_texture()
	sprite.modulate = _mode_color(mode)
	u.add_child(sprite)

	u.collision_layer = 2
	u.collision_mask  = 15
	return u

func _diamond_texture() -> ImageTexture:
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	for x in range(8):
		for y in range(8):
			var dx: float = abs(x - 3.5)
			var dy: float = abs(y - 3.5)
			if dx + dy > 3.5:
				img.set_pixel(x, y, Color.TRANSPARENT)
	return ImageTexture.create_from_image(img)

func _mode_color(mode: String) -> Color:
	match mode:
		"spread":   return Color(0.3, 1.0, 0.4)
		"bounce":   return Color(0.3, 0.7, 1.0)
		"big":      return Color(1.0, 0.5, 0.1)
		"tracking": return Color(1.0, 0.25, 1.0)
		"cardinal": return Color(1.0, 0.9, 0.2)
	return Color.WHITE