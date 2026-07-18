class_name FadeNode extends Node

@export var return_when_done : bool = false
@export var target_modulate_queue : Array[Color] = []
@export var target_modulate : Color = Color(0,0,0,0)
@export var modulate_step : float = 0.2
@export var time_step : float = 0.5

var return_modulate : Color 

var timer := Timer.new()

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	if(return_when_done):
		return_modulate = get_parent().modulate

func set_target_modulate(color : Color, mod_step : float, set_time_step : float):
	target_modulate = color
	modulate_step = mod_step
	time_step = set_time_step

func get_stepped_value(mod_val : float, target_val : float):
	var ret_val = mod_val
	if(mod_val < target_val):
		ret_val = mod_val + modulate_step
		if(ret_val > target_val):
			ret_val = target_val
	else:
		ret_val = mod_val - modulate_step
		if(ret_val < target_val):
			ret_val = target_val
	return ret_val

func handle_modulate_step():
	var parent : Node2D = get_parent()
	var mod_r = parent.modulate.r
	var mod_g = parent.modulate.g
	var mod_b = parent.modulate.b
	var mod_a = parent.modulate.a
	
	var target_r = target_modulate.r
	var target_g = target_modulate.g
	var target_b = target_modulate.b
	var target_a = target_modulate.a
	
	var new_r = get_stepped_value(mod_r,target_r)
	var new_g = get_stepped_value(mod_g,target_g)
	var new_b = get_stepped_value(mod_b,target_b)
	var new_a = get_stepped_value(mod_a,target_a)
	
	var new_modulate = Color(new_r,new_g,new_b,new_a)
	
	parent.modulate = new_modulate
	if(new_modulate == target_modulate):
		if(target_modulate_queue.size() > 0):
			target_modulate = target_modulate_queue.pop_front()
		elif(return_when_done):
			target_modulate = return_modulate
			return_when_done = false
		else:
			queue_free()
	else:
		timer.start(time_step)

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		handle_modulate_step()
