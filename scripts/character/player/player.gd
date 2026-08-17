class_name Player extends Node2D

@export var familiar_team : Array[Familiar] = []
var stored_familiars : Array[Familiar] = []
@export var pentacle_charms : int = 0

var facing_direction : String = "down"
var walking : bool = false
var moving : bool = false

@onready var body : AnimatedSprite2D = $body
@onready var head : AnimatedSprite2D = $head
@onready var flash_light : PointLight2D = $PointLight2D
@onready var move_collider : Area2D = $move_collider

var move_speed_vect : Vector2 = Vector2(0,0)
var input_frozen = false
var can_move = true

var starting_battle : bool = false
var battle_underway : bool = false
var staged_encounter : Encounter = null
var encounter_on_control_return : Encounter = null

var showing_summary = false

@export var active : bool = true

var can_play_step_sound : bool = true

var grid_aligned_callback_node : Node = null

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0,0,0,1))
	head.play(facing_direction)
	fade_in()

func get_familiars_team() -> Array[Familiar]:
	return familiar_team

func set_familiars_team(in_team : Array[Familiar]):
	familiar_team.clear()
	familiar_team.append_array(in_team)

func get_stored_familiars() -> Array[Familiar]:
	return stored_familiars

func set_stored_familiars(in_familiars : Array[Familiar]):
	stored_familiars.clear()
	stored_familiars.append_array(in_familiars)

func get_pentacle_charms() -> int:
	return pentacle_charms

func set_pentacle_charms(num : int):
	pentacle_charms = num

func turn_on_flashlight():
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	if gamestate.get_state_map_value("HAS_LAMP") == "TRUE":
		flash_light.enabled = true

func turn_off_flashlight():
	flash_light.enabled = false

func freeze_input():
	input_frozen = true

func unfreeze_input():
	input_frozen = false
	if(encounter_on_control_return != null):
		start_encounter(encounter_on_control_return)

func set_encounter_on_unfreeze_input(encounter : Encounter):
	encounter_on_control_return = encounter

func input_is_frozen() -> bool:
	return input_frozen

func handle_input():
	if(not input_is_frozen() and not fader_is_fading()):
		if(Input.is_action_pressed("up")):
			if(grid_aligned()):
				walking = true
				facing_direction = "up"
		elif(Input.is_action_pressed("down")):
			if(grid_aligned()):
				walking = true
				facing_direction = "down"
		elif(Input.is_action_pressed("left")):
			if(grid_aligned()):
				walking = true
				facing_direction = "left"
		elif(Input.is_action_pressed("right")):
			if(grid_aligned()):
				walking = true
				facing_direction = "right"
		else:
			walking = false
		if(Input.is_action_just_pressed("dev")):
			var encounter = load("res://battle/encounters/test_encounter.tscn").instantiate()
			add_child(encounter)
			start_encounter(encounter)
		if(Input.is_action_pressed("select")):
			if(familiar_team.size() > 0):
				if(not showing_summary && $input_timer.is_stopped()):
					if(get_tree().get_first_node_in_group("rain_effect") != null):
						var rain_effect = get_tree().get_first_node_in_group("rain_effect")
						if(rain_effect.is_active()):
							rain_effect.visible = false
					showing_summary = true
					show_summary()
					get_tree().paused = true
					$input_timer.start(0.5)
				elif(showing_summary):
					if(get_tree().get_first_node_in_group("rain_effect") != null):
						var rain_effect = get_tree().get_first_node_in_group("rain_effect")
						if(rain_effect.is_active()):
							rain_effect.visible = true
					showing_summary = false
					$AudioStreamPlayer.stream = load("res://audio/effects/bell_quick.ogg")
					$AudioStreamPlayer.play()
		if(Input.is_action_just_pressed("action_1")):
			if(grid_aligned() and $input_timer.is_stopped()):
				handle_interact()

func play_sound(stream : AudioStream):
	$AudioStreamPlayer.stream = stream
	$AudioStreamPlayer.play()

func start_input_timer(time : float):
	$input_timer.start(time)

func show_summary():
	if(familiar_team.size() > 0):
		var summary : FamiliarSummary = load("res://interface/familiar_summary.tscn").instantiate()
		get_parent().add_child(summary)
		summary.set_familiars(familiar_team)
		var camera : Camera2D = get_tree().get_first_node_in_group("camera")
		var pos : Vector2 = camera.get_screen_center_position()
		summary.global_position = pos

func handle_animation():
	if(moving):
		head.speed_scale = 3.0
		var animation_name : String =str("walk_",facing_direction)
		if(body.animation != animation_name):
			body.play(animation_name)
		if(body.frame == 1 || body.frame == 3):
			if(can_play_step_sound):
				$footfall_player.stream = load("res://audio/effects/step.ogg")
				$footfall_player.play()
				can_play_step_sound = false
		else:
			can_play_step_sound = true
	else:
		head.speed_scale = 1.0
		var animation_name : String =str("stand_",facing_direction)
		if(body.animation != animation_name):
			body.play(animation_name)
	if(head.animation != facing_direction):
		var keep_frame : int = head.frame
		var keep_progress : float = head.frame_progress
		head.play(facing_direction)
		head.frame = keep_frame
		head.frame_progress = keep_progress

func start_encounter(encounter :Encounter):
	if(starting_battle == false):
		starting_battle = true
		staged_encounter = encounter
		can_move = false
		fade_out()
		$AudioStreamPlayer.stream = load("res://audio/effects/encounter.ogg")
		$AudioStreamPlayer.play()

func fader_is_fading() -> bool:
	var is_fading : bool = false
	if($fade_to_black.get_child_count() > 0):
		is_fading = true
	return is_fading

func start_battle():
	battle_underway = true
	starting_battle = false
	disable_overworld()
	var opponent_familiars : Array[Familiar] = staged_encounter.get_opponents()
	var input_familiars : Array[Familiar] = []
	for familiar in opponent_familiars:
		add_child(familiar)
		input_familiars.append(familiar)
	#for familiar in familiar_team:
		#add_child(familiar)
	var battle_system : BattleSystemManager = load("res://battle/battle_system.tscn").instantiate()
	get_parent().add_child(battle_system)
	var camera : Camera2D = get_tree().get_first_node_in_group("camera")
	var pos : Vector2 = camera.get_screen_center_position()
	battle_system.global_position = pos
	battle_system.play_music(staged_encounter.get_music())
	var player_input_familiars : Array[Familiar] = []
	for familiar in familiar_team:
		player_input_familiars.append(familiar)
	battle_system.set_familiars(player_input_familiars,input_familiars)
	set_inactive()

func end_battle(end_player_familiars : Array[Familiar]):
	familiar_team.clear()
	for familiar in end_player_familiars:
		familiar_team.append(familiar)
		familiar.reparent(self)
		familiar.set_inactive()
	var battle_system : = get_tree().get_first_node_in_group("battle_system")
	battle_system.queue_free()
	staged_encounter.queue_free()
	var evolving_familiars : Array[Familiar] = []
	for familiar in familiar_team:
		if(familiar.is_ready_to_evolve()):
			evolving_familiars.append(familiar)
	if(evolving_familiars.size() > 0):
		var evolution_interface : FamiliarEvolve
		evolution_interface = load("res://interface/familiar_evolve.tscn").instantiate()
		get_parent().add_child(evolution_interface)
		var camera : Camera2D = get_tree().get_first_node_in_group("camera")
		var pos : Vector2 = camera.get_screen_center_position()
		evolution_interface.global_position = pos
		evolution_interface.set_evolving_familiars(evolving_familiars)
	else:
		return_to_overworld()

func return_to_overworld():
	var global_modulate = get_tree().get_first_node_in_group("global_modulate")
	if(global_modulate != null):
		global_modulate.visible = true
	var global_music = get_tree().get_first_node_in_group("global_music_player")
	if(global_music != null):
		global_music.play()
	set_active()
	can_move = true
	fade_in()

func disable_overworld():
	var global_modulate = get_tree().get_first_node_in_group("global_modulate")
	if(global_modulate != null):
		global_modulate.visible = false
	var global_music = get_tree().get_first_node_in_group("global_music_player")
	if(global_music != null):
		global_music.stop()

func fade_in():
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	var fade_out = Color(1,1,1,0)
	fade_node.set_target_modulate(fade_out,0.2,0.2)
	$fade_to_black.add_child(fade_node)

func fade_out():
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	var fade_out = Color(1,1,1,1)
	fade_node.set_target_modulate(fade_out,0.2,0.2)
	$fade_to_black.add_child(fade_node)

func handle_interact():
	match facing_direction:
		"up":
			if($move_collider_up.get_overlapping_bodies().size() > 0):
				for body in $move_collider_up.get_overlapping_bodies():
					if body.is_in_group("interactable"):
						interact_with(body)
		"down":
			if($move_collider_down.get_overlapping_bodies().size() > 0):
				for body in $move_collider_down.get_overlapping_bodies():
					if body.is_in_group("interactable"):
						interact_with(body)
		"left":
			if($move_collider_left.get_overlapping_bodies().size() > 0):
				for body in $move_collider_left.get_overlapping_bodies():
					if body.is_in_group("interactable"):
						interact_with(body)
		"right":
			if($move_collider_right.get_overlapping_bodies().size() > 0):
				for body in $move_collider_right.get_overlapping_bodies():
					if body.is_in_group("interactable"):
						interact_with(body)

func interact_with(node : Node):
	node.interact()
	walking = false
	moving = false
	move_speed_vect = Vector2(0,0)

func handle_movement():
	if(grid_aligned()):
		grid_aligned_callback()
	if(walking && can_move):
		var speed : int = 1
		if(grid_aligned() && can_move):
			match facing_direction:
				"up":
					if($move_collider_up.get_overlapping_bodies().size() == 0):
						move_speed_vect = Vector2(0,-speed)
						moving = true
					else:
						move_speed_vect = Vector2(0,0)
						moving = false
				"down":
					if($move_collider_down.get_overlapping_bodies().size() == 0):
						move_speed_vect = Vector2(0,speed)
						moving = true
					else:
						move_speed_vect = Vector2(0,0)
						moving = false
				"left":
					if($move_collider_left.get_overlapping_bodies().size() == 0):
						move_speed_vect = Vector2(-speed,0)
						moving = true
					else:
						move_speed_vect = Vector2(0,0)
						moving = false
				"right":
					if($move_collider_right.get_overlapping_bodies().size() == 0):
						move_speed_vect = Vector2(speed,0)
						moving = true
					else:
						move_speed_vect = Vector2(0,0)
						moving = false
	else:
		if(grid_aligned()):
			move_speed_vect = Vector2(0,0)
			moving = false
	global_position = global_position + move_speed_vect

func stop():
	walking = false

func grid_aligned() -> bool:
	return fmod(global_position.x,24) == 0 && fmod(global_position.y,24) == 0

func is_active() -> bool:
	return active

func set_active():
	active = true
	$PointLight2D.enabled = true

func set_inactive():
	active = false
	$PointLight2D.enabled = false

func set_grid_aligned_callback(node : Node):
	grid_aligned_callback_node = node

func grid_aligned_callback():
	if(grid_aligned_callback_node != null):
		grid_aligned_callback_node.grid_aligned_callback()
		grid_aligned_callback_node = null

func end_awaiting_input():
	unfreeze_input()
	start_input_timer(0.5)

func play_texts(texts : Array[Text]):
	stop()
	var string_texts : Array[String]
	for text : Text in texts:
		var text_string : String = text.get_text("english")
		string_texts.append(text_string)
	freeze_input()
	$InterfaceMessageSpeech.queue_text(string_texts)
	var camera : Camera2D = get_tree().get_first_node_in_group("camera")
	var pos : Vector2 = camera.get_screen_center_position()
	$InterfaceMessageSpeech.global_position = pos + Vector2(-64,80)

func _physics_process(delta: float) -> void:
	if(active):
		handle_input()
		handle_animation()
		handle_movement()
	if(starting_battle && not fader_is_fading()):
		start_battle()
	
	
