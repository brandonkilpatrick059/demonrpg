extends StaticBody2D
@export var seal_name : String = ""

func _ready() -> void:
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	if(gamestate.get_state_map_value(seal_name) == "GATHERED"):
		queue_free()


func interact():
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	var num_charms = player_ref.get_pentacle_charms()
	player_ref.set_pentacle_charms(num_charms + 1)
	player_ref.play_texts([$Text])
	player_ref.play_sound(load("res://audio/effects/capture.ogg"))
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	gamestate.set_state_map_value(seal_name,"GATHERED")
	queue_free()
