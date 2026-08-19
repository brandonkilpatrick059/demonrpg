extends StaticBody2D

var action_menu : GenericActionMenu = null
var summary : FamiliarSummary = null

var audio_player := AudioStreamPlayer.new()

var sacrifice_mode : bool = false
var grimoire_mode : bool = false
var view_all_familiars_mode : bool = false
var store_familiars_mode : bool = false
var summmon_familiars_mode : bool = false
var main_mode : bool = true

func _ready():
	#TODO: buses and stuff
	add_child(audio_player)

func interact():
	action_menu = load("res://interface/generic_action_menu.tscn").instantiate()
	add_child(action_menu)
	var camera : Camera2D = get_tree().get_first_node_in_group("camera")
	action_menu.global_position = camera.get_screen_center_position()
	set_basic_actions()
	main_mode = true
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
	if(main_mode):
		exit_altar()

func exit_altar():
	action_menu.queue_free()
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	player_ref.unfreeze_input()
	audio_player.stream = load("res://audio/effects/brush_snare.ogg")
	audio_player.play()

func list_team():
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	var familiars : Array[Familiar] = player_ref.get_familiars_team()
	var names : Array[String] = []
	for familiar : Familiar in familiars:
		names.append(familiar.get_familiar_name())
	names.append("BACK")
	action_menu.set_actions(names)

func list_stored():
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	var familiars : Array[Familiar] = player_ref.get_stored_familiars()
	var names : Array[String] = []
	for familiar : Familiar in familiars:
		names.append(familiar.get_familiar_name())
	names.append("BACK")
	action_menu.set_actions(names)

func handle_grimoire():
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	var actions : Array[String] = ["VIEW ALL"]
	if(player_ref.get_familiars_team().size() < 4 && player_ref.get_stored_familiars().size() > 0):
		actions.append("ROUSE")
	elif(player_ref.get_familiars_team().size() == 4 && player_ref.get_stored_familiars().size() > 0):
		actions.append("ROUSE (FULL)")
	elif(player_ref.get_stored_familiars().size() == 0):
		actions.append("ROUSE (EMPTY)")
	if(player_ref.get_familiars_team().size() > 0 && player_ref.get_stored_familiars().size() < 6):
		actions.append("STORE")
	elif(player_ref.get_familiars_team().size() == 0 && player_ref.get_stored_familiars().size() < 6):
		actions.append("STORE (EMPTY)")
	elif(player_ref.get_stored_familiars().size() == 8):
		actions.append("STORE (FULL)")
	actions.append("BACK")
	action_menu.set_actions(actions)

func handle_summon():
	list_stored()

func show_summary(familiars : Array[Familiar]):
	summary = load("res://interface/familiar_summary.tscn").instantiate()
	get_parent().add_child(summary)
	summary.set_familiars(familiars)
	var camera : Camera2D = get_tree().get_first_node_in_group("camera")
	var pos : Vector2 = camera.get_screen_center_position()
	summary.global_position = pos

func handle_view_all():
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	var all_familiars : Array[Familiar] = []
	all_familiars.append_array(player_ref.get_familiars_team())
	all_familiars.append_array(player_ref.get_stored_familiars())
	show_summary(all_familiars)
	action_menu.set_inactive()

func handle_store():
	list_team()

func take_action(action : String):
	if(store_familiars_mode):
		if(action == "BACK"):
			store_familiars_mode = false
			grimoire_mode = true
			handle_grimoire()
			audio_player.stream = load("res://audio/effects/brush_snare.ogg")
			audio_player.play()
		else:
			var player_ref : Player = get_tree().get_first_node_in_group("player")
			var familiars : Array[Familiar] = player_ref.get_familiars_team()
			var selected_familiar : Familiar
			for familiar : Familiar in familiars:
				var familiar_name = familiar.get_familiar_name()
				if(action == familiar_name):
					selected_familiar = familiar
			familiars.erase(selected_familiar)
			player_ref.get_stored_familiars().append(selected_familiar)
			store_familiars_mode = false
			grimoire_mode = true
			audio_player.stream = load("res://audio/effects/evil_eye.ogg")
			audio_player.play()
			handle_grimoire()
	elif(summmon_familiars_mode):
		if(action == "BACK"):
			summmon_familiars_mode = false
			grimoire_mode = true
			handle_grimoire()
			audio_player.stream = load("res://audio/effects/brush_snare.ogg")
			audio_player.play()
		else:
			var player_ref : Player = get_tree().get_first_node_in_group("player")
			var familiars : Array[Familiar] = player_ref.get_stored_familiars()
			var selected_familiar : Familiar
			for familiar : Familiar in familiars:
				var familiar_name = familiar.get_familiar_name()
				if(action == familiar_name):
					selected_familiar = familiar
			familiars.erase(selected_familiar)
			player_ref.get_familiars_team().append(selected_familiar)
			summmon_familiars_mode = false
			grimoire_mode = true
			handle_grimoire()
			audio_player.stream = load("res://audio/effects/capture.ogg")
			audio_player.play()
	elif(grimoire_mode):
		match action:
			"VIEW ALL":
				grimoire_mode = false
				view_all_familiars_mode = true
				handle_view_all()
			"ROUSE":
				grimoire_mode = false
				summmon_familiars_mode = true
				handle_summon()
				audio_player.stream = load("res://audio/effects/bell_quicker.ogg")
				audio_player.play()
			"STORE":
				grimoire_mode = false
				store_familiars_mode = true
				handle_store()
				audio_player.stream = load("res://audio/effects/bell_quicker.ogg")
				audio_player.play()
			"BACK":
				set_basic_actions()
				main_mode = true
				grimoire_mode = false
				audio_player.stream = load("res://audio/effects/brush_snare.ogg")
				audio_player.play()
	elif(sacrifice_mode):
		if(action == "BACK"):
			set_basic_actions()
			main_mode = true
			sacrifice_mode = false
			audio_player.stream = load("res://audio/effects/brush_snare.ogg")
			audio_player.play()
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
			main_mode = true
			sacrifice_mode = false
			player_ref.start_encounter(encounter)
			audio_player.stream = load("res://audio/effects/bell_quicker.ogg")
			audio_player.play()
	elif(main_mode):
		match action:
			"LEAVE":
				exit_altar()
			"GRIMOIRE":
				main_mode = false
				grimoire_mode = true
				handle_grimoire()
				audio_player.stream = load("res://audio/effects/bell_quicker.ogg")
				audio_player.play()
			"SACRIFICE":
				main_mode = false
				sacrifice_mode = true
				list_team()
				audio_player.stream = load("res://audio/effects/bell_quicker.ogg")
				audio_player.play()

func _physics_process(delta: float) -> void:
	if(view_all_familiars_mode and (Input.is_action_just_pressed("action_2") || 
	Input.is_action_just_pressed("select"))):
		view_all_familiars_mode = false
		grimoire_mode = true
		handle_grimoire()
		action_menu.set_active()
		audio_player.stream = load("res://audio/effects/brush_snare.ogg")
		audio_player.play()
	elif(grimoire_mode and Input.is_action_just_pressed("action_2")):
		set_basic_actions()
		main_mode = true
		grimoire_mode = false
		audio_player.stream = load("res://audio/effects/brush_snare.ogg")
		audio_player.play()
	elif(sacrifice_mode and Input.is_action_just_pressed("action_2")):
		set_basic_actions()
		main_mode = true
		sacrifice_mode = false
		audio_player.stream = load("res://audio/effects/brush_snare.ogg")
		audio_player.play()
	elif(store_familiars_mode and Input.is_action_just_pressed("action_2")):
		handle_grimoire()
		grimoire_mode = true
		store_familiars_mode = false
		audio_player.stream = load("res://audio/effects/brush_snare.ogg")
		audio_player.play()
	elif(summmon_familiars_mode and Input.is_action_just_pressed("action_2")):
		handle_grimoire()
		grimoire_mode = true
		summmon_familiars_mode = false
		audio_player.stream = load("res://audio/effects/brush_snare.ogg")
		audio_player.play()
	elif(main_mode and Input.is_action_just_pressed("action_2")):
		if(action_menu != null):
			exit_altar()
