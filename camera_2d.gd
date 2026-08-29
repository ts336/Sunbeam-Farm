extends Camera2D

# Smoothly transitions the camera zoom level over time
func zoom_to(target_zoom: Vector2, duration: float = 0.5) -> void:
	var tween = create_tween()
	# Transition camera zoom smoothly using a ease-out curve
	tween.tween_property(self, "zoom", target_zoom, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
