extends StaticBody2D
@export var gore_name : String = ""
@export var heal_amount : int = 5

func _ready() -> void:
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	if(gamestate.get_state_map_value(gore_name) == "GATHERED"):
		queue_free()


func interact():
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	var num_charms = player_ref.get_pentacle_charms()
	player_ref.set_pentacle_charms(num_charms + 1)
	player_ref.play_texts([$Text])
	player_ref.play_sound(load("res://audio/effects/feed.ogg"))
	var familiars : Array[Familiar] = player_ref.get_familiars_team()
	for familiar : Familiar in familiars:
		if(familiar.get_current_hp() + heal_amount > familiar.get_max_hp()):
			familiar.set_current_hp(familiar.get_max_hp())
		else:
			familiar.set_current_hp(familiar.get_current_hp() + heal_amount)
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	gamestate.set_state_map_value(gore_name,"GATHERED")
	queue_free()
