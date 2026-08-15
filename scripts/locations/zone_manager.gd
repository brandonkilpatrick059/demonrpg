class_name ZoneManager extends Node2D

@export var current_zone : Node

var switching_zones : bool = false
var switching_to_zone : PackedScene
var to_link_name : String = ""
var first_phase : bool = false
var second_phase : bool = false
var fading_in : bool = false
var destination_link : ZoneLink

var player_ref : Player

var timer := Timer.new()

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	add_to_group("zone_manager")
	timer.one_shot = true
	add_child(timer)
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
