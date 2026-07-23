extends AnimatedSprite2D

@export var random_frame : bool = false

func _ready() -> void:
	if(random_frame):
		frame = randi_range(0,sprite_frames.get_frame_count("default"))
	play("default")
