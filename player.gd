extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ground: TileMapLayer = $"../Ground"
@onready var farm_manager = $"../FarmManager"

const SPEED = 100.0

var last_direction = "forward"
var tilling = false

func _ready():
	animated_sprite_2d.play("Idle_forward")

func _physics_process(delta: float) -> void:	
	# 1. Stop processing input/movement if currently harvesting
	if tilling:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "forward", "back")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		# Update last known direction based on input
		if abs(direction.x) > abs(direction.y):
			last_direction = "right" if direction.x > 0 else "left"
		else:
			last_direction = "forward" if direction.y > 0 else "back"
			# Play walk animation
		animated_sprite_2d.play(last_direction)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		# Play idle animation matching the last direction
		animated_sprite_2d.play("Idle_" + last_direction)	
	
	move_and_slide()

func get_current_cell() -> Vector2i:
	var local_pos = farm_manager.ground.to_local(global_position)
	return farm_manager.ground.local_to_map(local_pos)

#CHANGE MOUSE CLICK
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				till_ground()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				harvest_crop()


func till_ground() -> void:

	if tilling:
		return

	# 1. Convert player's global position into ground's local space
	var local_pos = ground.to_local(global_position)

	# 2. Convert local pixels into integer grid coordinates (e.g., Vector2i(3, 1))
	var cell: Vector2i = ground.local_to_map(local_pos)

	# Debug prints
	print("Player Global Position: ", global_position)
	print("Target Cell: ", cell) # Will output grid coords like (3, 1) instead of (50, 23)
	print("Cell Local Pos: ", ground.map_to_local(cell))

	tilling = true

	animated_sprite_2d.play(
		"Till_forward"
	)

	await animated_sprite_2d.animation_finished

	farm_manager.till(cell)

	tilling = false

func harvest_crop() -> void:

	var cell = get_current_cell()

	var harvested = farm_manager.harvest(cell)

	if harvested:
		print("Wheat harvested!")

# In player.gd (Optional Helper)
func teleport_to(target_position: Vector2) -> void:
	global_position = target_position
	velocity = Vector2.ZERO # Stops any leftover sliding momentum
