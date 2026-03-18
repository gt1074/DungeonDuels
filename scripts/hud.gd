extends CanvasLayer

@export var heart_full: Texture2D
@export var heart_half: Texture2D
@export var heart_empty: Texture2D
@export var max_health: int = 5

@onready var hearts_container = $Hearts

func _ready():
	draw_hearts(5)

func draw_hearts(current_health: int):
	for child in hearts_container.get_children():
		child.queue_free()
	
	for i in range(max_health):
		var heart = TextureRect.new()
		if i < current_health:
			heart.texture = heart_full
		else:
			heart.texture = heart_empty
		heart.stretch_mode = TextureRect.STRETCH_KEEP
		hearts_container.add_child(heart)

func update_hearts(current_health: int):
	draw_hearts(current_health)
	
