extends StaticBody2D
@export var damned_name : String = ""

var interacted : bool = false
@export var familiar_path : String = ""

func _ready() -> void:
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	if(gamestate.get_state_map_value(damned_name) == "GATHERED"):
		queue_free()

func gather() -> void:
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	gamestate.set_state_map_value(damned_name,"GATHERED")
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	player_ref.play_sound(load("res://audio/effects/capture.ogg"))
	player_ref.play_texts([$capture])
	var damned : Familiar = load(familiar_path).instantiate()
	damned.set_inactive()
	player_ref.add_child(damned)
	player_ref.familiar_team.append(damned)
	queue_free()

func _physics_process(delta: float) -> void:
	if(interacted):
		var player_ref : Player = get_tree().get_first_node_in_group("player")
		if player_ref.get_familiars_team().size() < 4:
			if(player_ref.global_position.distance_to(global_position) > 48):
				gather()

func interact():
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	var num_charms = player_ref.get_pentacle_charms()
	player_ref.set_pentacle_charms(num_charms + 1)
	player_ref.play_texts([$Text1,$Text2])
	interacted = true
