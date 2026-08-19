extends CanvasLayer

func _ready() -> void:
	var screen_vector : Vector2 = get_viewport().get_visible_rect().size
	if(screen_vector.x == 320 && screen_vector.y == 180):
		$screen_effect_320x180.visible = true
		$screen_effect_300x180.visible = false
		$screen_effect_316x160.visible = false
	elif(screen_vector.x == 316 && screen_vector.y == 160):
		$screen_effect_320x180.visible = false
		$screen_effect_300x180.visible = false
		$screen_effect_316x160.visible = true
	elif(screen_vector.x == 300 && screen_vector.y == 180):
		$screen_effect_320x180.visible = false
		$screen_effect_300x180.visible = true
		$screen_effect_316x160.visible = false
