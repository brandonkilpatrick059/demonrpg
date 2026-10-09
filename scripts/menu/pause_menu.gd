extends Node2D

@onready var settings : Label = $menu/VBoxContainer/settings
@onready var controls : Label = $menu/VBoxContainer/controls
@onready var return_to_game : Label = $menu/VBoxContainer/return
@onready var quit : Label = $menu/VBoxContainer/quit

var selected_index : int = 0

var menu_buttons : Array[String] = []
var menu_labels : Array[Label] = []

var transition_to_scene : PackedScene = null

var active : bool = false
var parent_menu : Node = null

func set_parent_menu(menu : Node):
	parent_menu = menu

func _ready() -> void:
	active = true
	$AudioStreamPlayer.stream = load("res://audio/effects/bell_quick.ogg")
	$AudioStreamPlayer.play()
	menu_buttons = ["SETTINGS","CONTROLS","RETURN","QUIT"]
	menu_labels = [settings,controls,return_to_game,quit]

func handle_control():
	if(Input.is_action_just_pressed("down")):
		if selected_index < menu_buttons.size() - 1:
			selected_index = selected_index + 1
			$AudioStreamPlayer.stream = load("res://audio/effects/click.ogg")
			$AudioStreamPlayer.play()
	elif(Input.is_action_just_pressed("up")):
		if selected_index > 0:
			selected_index = selected_index - 1
			$AudioStreamPlayer.stream = load("res://audio/effects/click.ogg")
			$AudioStreamPlayer.play()
	elif(Input.is_action_just_pressed("action_1")):
		var selection : String = menu_buttons[selected_index]
		match selection:
			"SETTINGS": #just audio for now
				var audio_menu = load("res://menu/audio_menu.tscn").instantiate()
				var camera : Camera2D = get_tree().get_first_node_in_group("camera")
				audio_menu.global_position = camera.get_screen_center_position()
				add_child(audio_menu)
				audio_menu.set_parent_menu(self)
				$AudioStreamPlayer.stream = load("res://audio/effects/bell_quicker.ogg")
				$AudioStreamPlayer.play()
				set_inactive()
			"CONTROLS":
				var controls_menu = load("res://menu/controls_menu.tscn").instantiate()
				var camera : Camera2D = get_tree().get_first_node_in_group("camera")
				controls_menu.global_position = camera.get_screen_center_position()
				get_parent().add_child(controls_menu)
				controls_menu.set_parent_menu(self)
				$AudioStreamPlayer.stream = load("res://audio/effects/bell_quicker.ogg")
				$AudioStreamPlayer.play()
				set_inactive()
			"CONTROLS":
				pass #TODO: implement
			"RETURN":
				get_tree().paused = false
				var player : Player = get_tree().get_first_node_in_group("player")
				player.play_sound(load("res://audio/effects/bell_quicker.ogg"))
				queue_free()
			"QUIT":
				#TODO: are you sure?
				var main_menu : PackedScene = load("res://menu/main_menu.tscn")
				get_tree().paused = false
				get_tree().change_scene_to_packed(main_menu)
	elif(Input.is_action_just_pressed("menu") || 
	Input.is_action_just_pressed("action_2")):
		get_tree().paused = false
		queue_free()

func set_inactive():
	active = false

func set_active():
	active = true

func fade_out():
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	var fade_out = Color(1,1,1,1)
	var fade_black = get_tree().get_first_node_in_group("fade_black")
	fade_node.set_target_modulate(fade_out,0.1,0.2)
	fade_black.add_child(fade_node)

func _physics_process(delta: float) -> void:
	var camera : Camera2D = get_tree().get_first_node_in_group("camera")
	global_position = camera.get_screen_center_position()
	if(active):
		var index = 0
		for label in menu_labels:
			if(index == selected_index):
				label.modulate = Color(1.0,0,0.75,1.0)
			else:
				label.modulate = Color(1,1,1,1)
			index = index + 1
		handle_control()
	elif(transition_to_scene != null):
		var fade_black = get_tree().get_first_node_in_group("fade_black")
		if(fade_black.modulate.a == 1.0):
			get_tree().change_scene_to_packed(transition_to_scene)
	
