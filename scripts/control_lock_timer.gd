extends Node

var timer := Timer.new()
@export var wait : float = 0.0

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	timer.start(wait)
	
func _physics_process(delta: float) -> void:
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	player_ref.freeze_input()
	if(timer.is_stopped()):
		player_ref.unfreeze_input()
		queue_free()
		
