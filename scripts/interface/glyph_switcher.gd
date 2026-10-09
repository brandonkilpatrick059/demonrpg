extends Node2D

@export var glyph_sets : Array[Node]

var timer := Timer.new()

@export var switch_time : float = 1.0

var current_index : int = 0

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	timer.start(switch_time)

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		var index = 0
		while(index < glyph_sets.size()):
			if(index == current_index):
				glyph_sets[index].visible = true
			else:
				glyph_sets[index].visible = false
			index = index + 1
		current_index = current_index + 1
		timer.start(switch_time)
	if(current_index >= glyph_sets.size()):
		current_index = 0
