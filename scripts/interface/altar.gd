extends StaticBody2D

var action_menu : GenericActionMenu = null

var audio_player := AudioStreamPlayer.new()

var sacrifice_mode : bool = false

func _ready():
	#TODO: buses and stuff
	add_child(audio_player)

func interact():
	action_menu = load("res://interface/generic_action_menu.tscn").instantiate()
	add_child(action_menu)
	var camera : Camera2D = get_tree().get_first_node_in_group("camera")
	action_menu.global_position = camera.get_screen_center_position()
	set_basic_actions()
	action_menu.set_active()
	action_menu.set_parent_node(self)
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	player_ref.freeze_input()
	audio_player.stream = load("res://audio/effects/bell_full_low.ogg")
	audio_player.play()

func set_basic_actions():
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	var actions : Array[String] = []
	if(player_ref.get_familiars_team().size() > 1):
		actions.append("SACRIFICE")
	actions.append_array(["GRIMOIRE","SAVE GAME","LEAVE"])
	action_menu.set_actions(actions)

func action_menu_exit():
	exit_altar()

func exit_altar():
	action_menu.queue_free()
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	player_ref.unfreeze_input()
	audio_player.stream = load("res://audio/effects/brush_snare.ogg")
	audio_player.play()

func handle_sacrifice():
	sacrifice_mode = true
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	var familiars : Array[Familiar] = player_ref.get_familiars_team()
	var names : Array[String] = []
	for familiar : Familiar in familiars:
		names.append(familiar.get_familiar_name())
	names.append("BACK")
	action_menu.set_actions(names)

func take_action(action : String):
	if(sacrifice_mode):
		if(action == "BACK"):
			set_basic_actions()
			sacrifice_mode = false
		else:
			var player_ref : Player = get_tree().get_first_node_in_group("player")
			var familiars : Array[Familiar] = player_ref.get_familiars_team()
			var sacrificial_familiar : Familiar
			for familiar : Familiar in familiars:
				var familiar_name = familiar.get_familiar_name()
				if(action == familiar_name):
					sacrificial_familiar = familiar
			var encounter : Encounter = load("res://battle/encounters/empty_encounter.tscn").instantiate()
			sacrificial_familiar.reparent(encounter)
			encounter.add_opponent(sacrificial_familiar)
			familiars.erase(sacrificial_familiar)
			exit_altar()
			player_ref.start_encounter(encounter)
	else:
		match action:
			"LEAVE":
				exit_altar()
			"SACRIFICE":
				handle_sacrifice()
			
