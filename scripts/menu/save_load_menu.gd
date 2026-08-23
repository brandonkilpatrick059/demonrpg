class_name SaveLoadMenu extends Node2D

@onready var tabs : Array[SaveLoadTab] = [$SaveLoadTab,$SaveLoadTab2,
										$SaveLoadTab3,$SaveLoadTab4]
@onready var mode_label : Label = $mode
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var save_load_manager : SaveLoadManager = $save_load_manager

var selected_index : int = 0

var mode_save : bool = false
var mode_load : bool = false

var active : bool = true

var altar_ref : Altar = null

func _ready() -> void:
	update_save_slots()

func set_inactive():
	active = false

func set_mode_save():
	mode_save = true
	mode_load = false
	mode_label.text = "SAVE"

func set_mode_load():
	mode_save = false
	mode_load = true
	mode_label.text = "LOAD"

func update_save_slots():
	var index = 0
	for tab : SaveLoadTab in tabs:
		save_load_manager.get_load_tab(index,tab)
		index = index + 1

func update_selected():
	var index = 0
	for tab : SaveLoadTab in tabs:
		if(selected_index == index):
			tab.set_active()
		else:
			tab.set_inactive()
		index = index + 1

func handle_input():
	if(active):
		if(Input.is_action_just_pressed("up")):
			if(selected_index >= 1):
				selected_index = selected_index - 1
				audio_player.stream = load("res://audio/effects/click.ogg")
				update_selected()
			else:
				audio_player.stream = load("res://audio/effects/short_bell.ogg")
			audio_player.play()
		elif(Input.is_action_just_pressed("down")):
			if(selected_index < 3):
				selected_index = selected_index + 1
				audio_player.stream = load("res://audio/effects/click.ogg")
				update_selected()
			else:
				audio_player.stream = load("res://audio/effects/short_bell.ogg")
			audio_player.play()
		elif(Input.is_action_just_pressed("action_1")):
			if(mode_save):
				var location_name = altar_ref.get_location_name()
				var scene_file_path = altar_ref .get_scene_path()
				save_load_manager.save(selected_index,location_name,scene_file_path)
				update_save_slots()
				audio_player.stream = load("res://audio/effects/bell_full_low.ogg")
				audio_player.play()
			elif(mode_load):
				var zone_manager = get_tree().get_first_node_in_group("zone_manager")
				zone_manager.load_game_from_file(selected_index)
		elif(Input.is_action_just_pressed("action_2")):
			queue_free()

func set_location(altar : Altar):
	altar_ref = altar

func _physics_process(delta: float) -> void:
	handle_input()
	update_selected()
