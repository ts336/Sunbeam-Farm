extends CanvasLayer

@onready var wheat_label: Label = $WheatLabel
@onready var farm_manager = $"../FarmManager" # Adjust path to match your main scene tree


func _ready() -> void:
	# Connect signal from FarmManager
	if farm_manager:
		farm_manager.wheat_count_changed.connect(_on_wheat_count_changed)

func _on_wheat_count_changed(new_amount: int) -> void:
	wheat_label.text = "Wheat: " + str(new_amount) +"/10"
