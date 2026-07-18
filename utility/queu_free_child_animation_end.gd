extends Node2D

func _physics_process(delta: float) -> void:
	var sprite : AnimatedSprite2D = $AnimatedSprite2D
	var final_frame = sprite.sprite_frames.get_frame_count("default") - 1
	if(sprite.frame == final_frame):
		queue_free()
