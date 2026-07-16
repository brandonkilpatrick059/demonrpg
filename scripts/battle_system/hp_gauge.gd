class_name HPGauge extends AnimatedSprite2D

var timer := Timer.new()

var display_level : int = 0
var set_level : int = 0
var done_animating : bool = true

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

#sets the gauge to a percentage full
#input is as a float between 0.0 and 1.0
func set_gauge(fraction : float, no_animate : bool = false):
	var num_frames = sprite_frames.get_frame_count("default")
	set_level = (fraction * num_frames)
	if(no_animate):
		display_level = set_level
		update_gauge()
	done_animating = false

func update_gauge():
	frame = display_level

func animate_gauge():
	if(timer.is_stopped()):
		if(set_level != display_level):
			if(display_level > set_level):
				display_level = display_level - 1
			else:
				display_level = display_level + 1
		else:
			done_animating = true
		timer.start(0.25)

func is_finished_animating() -> bool:
	return done_animating

func _physics_process(delta: float) -> void:
	if(!done_animating):
		animate_gauge()
