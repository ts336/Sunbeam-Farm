extends Node2D

@onready var ground: TileMapLayer = $"../Ground"
@onready var wheat_container: Node2D = $"../Wheat"
@onready var player: CharacterBody2D = $"../Player"
@onready var camera_2d: Camera2D = $"../Player/Camera2D"

signal wheat_count_changed(new_amount: int)
const GROWTH_TIME := 5.0

# Define your target teleport coordinates (adjust to your preferred location)
const TELEPORT_LOCATION := Vector2(1100.0, 10.0)
const TARGET_WHEAT := 10

const TARGET_ZOOM := Vector2(8.0, 8.0)

enum CropStage {
 SEED,
 SPROUT,
 EARLY,
 FULL
}

var crops = {}
var wheat_sprites = {}

var growth_timer := 0.0
var wheat_count := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	growth_timer += delta

	if growth_timer >= 1.0:
		growth_timer -= 1.0
		growth_tick()


func growth_tick() -> void:
	for cell in crops:
		var crop = crops[cell]
		if crop["stage"] < CropStage.FULL:
			crop["time"] += 1.0
			if crop["time"] >= GROWTH_TIME:
				crop["time"] = 0.0
				crop["stage"] += 1
				update_wheat(cell)

func till(cell: Vector2i) -> void:
	# Don't till an already planted tile
	if crops.has(cell):
		return

	# Change this to whatever your tilled-ground tile is
	ground.set_cell(cell, 4, Vector2i(1, 1))
	
	# Create a new crop
	crops[cell] = {
		"stage": CropStage.SEED,
		"time": 0.0
	}

	update_wheat(cell)

func update_wheat(cell: Vector2i) -> void:
	if not crops.has(cell):
		return

	var crop = crops[cell]
	var sprite: Sprite2D

	# Create sprite ONLY if it doesn't already exist for this cell
	if wheat_sprites.has(cell):
		sprite = wheat_sprites[cell]
	else:
		sprite = Sprite2D.new()
		wheat_container.add_child(sprite)
		wheat_sprites[cell] = sprite

	# Align sprite to center of tile grid in global world space
	sprite.global_position = ground.to_global(ground.map_to_local(cell))
	sprite.centered = true # Ensures origin is middle of image

	var texture: Texture2D

	match crop["stage"]:
		CropStage.SEED:
			texture = preload("res://wheat_seed.png")
		CropStage.SPROUT:
			texture = preload("res://wheat_sprout.png")
		CropStage.EARLY:
			texture = preload("res://wheat_early.png")
		CropStage.FULL:
			texture = preload("res://wheat_full.png")

	sprite.texture = texture

func harvest(cell: Vector2i) -> bool:

	if not crops.has(cell):
		return false

	var crop = crops[cell]

	 # Can't harvest until fully grown
	if crop["stage"] != CropStage.FULL:
		return false

	 # Remove wheat sprite
	if wheat_sprites.has(cell):
		wheat_sprites[cell].queue_free()
		wheat_sprites.erase(cell)

	 # Remove crop data
	crops.erase(cell)
	
	wheat_count += 1
	wheat_count_changed.emit(wheat_count)
	
	# Check for the 10 wheat milestone
	if wheat_count == TARGET_WHEAT:
		teleport_player()

	return true

func teleport_player() -> void:
	if player:
		player.teleport_to(TELEPORT_LOCATION)
		print("Harvested 10 wheat! Player teleported to: ", TELEPORT_LOCATION)
		
		# Zoom camera in smoothly when teleporting
		if camera_2d:
			camera_2d.zoom_to(TARGET_ZOOM, 0.8)
			
		print("Harvested 10 wheat! Player teleported and camera zoomed.")
