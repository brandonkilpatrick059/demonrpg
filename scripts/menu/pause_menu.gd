extends Node2D

@onready var settings : Label = $menu/VBoxContainer/settings
@onready var controls : Label = $menu/VBoxContainer/controls
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
	menu_buttons = ["SETTINGS","CONTROLS","QUIT"]
	menu_labels = [settings,controls,quit]

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
			"SETTINGS":
				pass #TODO: implement
			"CONTROLS":
				pass #TODO: implement
			"QUIT":
				pass #TODO: implement

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
	elif(modulate.a == 1.0):
		active = true
	
