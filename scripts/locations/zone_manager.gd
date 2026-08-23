class_name ZoneManager extends Node2D

@export var current_zone : Node
@export var load_menu_on_ready : bool = false

var switching_zones : bool = false
var switching_to_zone : PackedScene
var to_link_name : String = ""
var first_phase : bool = false
var second_phase : bool = false
var fading_in : bool = false
var destination_link : ZoneLink
var game_loaded = false
var player_activated = false

var save_load_menu : SaveLoadMenu = null

var player_ref : Player

var timer := Timer.new()

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	add_to_group("zone_manager")
	timer.one_shot = true
	add_child(timer)
	if(load_menu_on_ready):
		save_load_menu = load("res://menu/save_load_menu.tscn").instantiate()
		get_parent().add_child(save_load_menu)
		var camera : Camera2D = get_tree().get_first_node_in_group("camera")
		save_load_menu.global_position = camera.get_screen_center_position()
		save_load_menu.set_mode_load()
		player_ref.freeze_input()
	else:
		if(current_zone.is_dark()):
			player_ref.turn_on_flashlight()
		else:
			player_ref.turn_off_flashlight()

func switch_zones(to_zone : PackedScene, to_link : String):
	switching_to_zone = to_zone
	to_link_name = to_link
	switching_zones = true
	player_ref.fade_out()
	player_ref.freeze_input()
	first_phase = true

func swap_zones():
	player_ref.reparent(self)
	current_zone.queue_free()
	current_zone = switching_to_zone.instantiate()
	if(current_zone.is_dark()):
		player_ref.turn_on_flashlight()
	else:
		player_ref.turn_off_flashlight()
	add_child(current_zone)
	player_ref.reparent(current_zone)
	destination_link = current_zone.get_link_by_name(to_link_name)
	player_ref.global_position = destination_link.get_teleport_position()
	second_phase = true
	timer.start(0.5)

func get_current_zone() -> LocationZone:
	return current_zone

func load_game_from_file(file_slot : int):
	if(not player_ref.fader_is_fading()):
		save_load_menu.set_inactive()
		$save_load_manager.setup_zone_manager_from_file(file_slot, self)

func load_game(load_scene_path : String, game_state_dictionary : Dictionary,
 	player_dictionary : Dictionary, familiars: Array[Familiar]):
	var load_zone = load(load_scene_path).instantiate()
	$Player.load_from_dictionary(player_dictionary)
	$gamestate.load_from_dictionary(game_state_dictionary)
	var familiar_team : Array[Familiar] = []
	var stored_familiars : Array[Familiar] = []
	for familiar : Familiar in familiars:
		if(familiar.is_stored()):
			stored_familiars.append(familiar)
		else:
			familiar_team.append(familiar)
		player_ref.add_child(familiar)
		familiar.set_inactive()
	player_ref.set_familiars_team(familiar_team)
	player_ref.set_stored_familiars(stored_familiars)
	player_ref.play_sound(load("res://audio/effects/bell_full_low.ogg"))
	current_zone = load_zone
	add_child(current_zone)
	current_zone.visible = false
	player_ref.visible = false
	game_loaded = true
	timer.start(3.0)

func _physics_process(delta: float) -> void:
	if(switching_zones):
		if(first_phase):
			if(not player_ref.fader_is_fading()):
				first_phase = false
				swap_zones()
		elif(second_phase):
			if(player_ref.global_position == destination_link.get_stop_point()):
				player_ref.stop()
			if(timer.is_stopped() and not fading_in):
				player_ref.fade_in()
				fading_in = true
			if(fading_in and not player_ref.fader_is_fading()):
				player_ref.unfreeze_input()
				switching_zones = false
				second_phase = false
				fading_in = false
	if(not game_loaded and save_load_menu != null and Input.is_action_just_pressed("action_2")):
		var main_menu : PackedScene = load("res://menu/main_menu.tscn")
		get_tree().change_scene_to_packed(main_menu)
	if(timer.is_stopped() and save_load_menu != null 
	and game_loaded):
		save_load_menu.queue_free()
		player_ref.visible = true
		var start_faded_out : bool = true
		player_ref.fade_in(start_faded_out)
		current_zone.visible = true
	if(not player_activated and save_load_menu == null and not $Player.fader_is_fading()):
		player_ref.unfreeze_input()
		player_activated = true
