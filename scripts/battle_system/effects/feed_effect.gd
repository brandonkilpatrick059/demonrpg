extends Node2D

var kill_node : Node = null

func set_kill_node(in_node : Node):
	kill_node = in_node

func _physics_process(delta: float) -> void:
	var sprite : AnimatedSprite2D = $AnimatedSprite2D
	if sprite.frame == 4:
		if(kill_node != null):
			kill_node.queue_free()
	var final_frame = sprite.sprite_frames.get_frame_count("default") - 1
	if(sprite.frame == final_frame):
		queue_free()
