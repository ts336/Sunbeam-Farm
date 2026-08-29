extends Node2D

@onready var animated_sprite_2d1 = $AnimatedSprite2D2
@onready var animated_sprite_2d2 = $AnimatedSprite2D3
@onready var animated_sprite_2d3 = $AnimatedSprite2D4

# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite_2d1.play("cow")
	animated_sprite_2d2.play("cow")
	animated_sprite_2d3.play("cow")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
