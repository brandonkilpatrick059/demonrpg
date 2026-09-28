extends StaticBody2D
@export var damned_name : String = ""

var interacted : bool = false
var showed_options : bool = false
@export var familiar_path : String = ""

var action_menu : GenericActionMenu

var interact_timer := Timer.new()

func _ready() -> void:
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	if(gamestate.get_state_map_value(damned_name) == "GATHERED"):
		queue_free()
	interact_timer.one_shot = true
	add_child(interact_timer)

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
		if(not player_ref.input_is_frozen() and not showed_options):
			show_action_menu()
			showed_options = true
		else:
			if player_ref.get_familiars_team().size() < 4:
				if(player_ref.global_position.distance_to(global_position) > 48):
					gather()

func show_action_menu():
	action_menu = load("res://interface/generic_action_menu.tscn").instantiate()
	add_child(action_menu)
	var camera : Camera2D = get_tree().get_first_node_in_group("camera")
	action_menu.global_position = camera.get_screen_center_position()
	action_menu.set_actions(["ATTACK","LEAVE"])
	action_menu.set_active()
	action_menu.set_parent_node(self)
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	player_ref.freeze_input()
	#audio_player.stream = load("res://audio/effects/brush_snare.ogg")
	#audio_player.play()

func take_action(action : String):
	if(action == "ATTACK"):
		start_battle()
	elif(action == "LEAVE"):
		exit_menu()

func start_battle():
	var familiar : Familiar = load(familiar_path).instantiate()
	var encounter : Encounter = load("res://battle/encounters/empty_encounter.tscn").instantiate()
	encounter.set_opponents([familiar])
	get_parent().add_child(encounter)
	familiar.set_inactive()
	encounter.add_child(familiar)
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	player_ref.unfreeze_input()
	player_ref.start_encounter(encounter)
	queue_free()

func exit_menu():
	action_menu.queue_free()
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	player_ref.unfreeze_input()
	#audio_player.stream = load("res://audio/effects/brush_snare.ogg")
	#audio_player.play()
	interact_timer.start(0.5)

func interact():
	if(interact_timer.is_stopped()):
		var player_ref : Player = get_tree().get_first_node_in_group("player")
		var num_charms = player_ref.get_pentacle_charms()
		player_ref.set_pentacle_charms(num_charms + 1)
		player_ref.play_texts([$Text1,$Text2])
		interacted = true
		showed_options = false
