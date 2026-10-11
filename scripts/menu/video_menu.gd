extends Node2D

@onready var aspect_ratio : Label = $menu/aspect_ratio
@onready var aspect_ratio_readout : Label = $menu/aspect_ratio_readout
@onready var full_screen : Label = $menu/full_screen
@onready var back : Label = $menu/back

var selected_index : int = 0
var menu_buttons : Array[String] = []
var menu_labels : Array[Label] = []

var aspect_ratios : Array[Vector2] = [Vector2(320,180),
Vector2(316,160),Vector2(300,180)]

var ratio_labels : Array[String] = ["A","B","C"]

var aspect_ratio_index = 0

var active : bool = false
var parent_menu : Node = null

func set_parent_menu(menu : Node):
	parent_menu = menu

func _ready() -> void:
	var viewport_vect : Vector2 = get_viewport().get_visible_rect().size
	aspect_ratio_index = aspect_ratios.find(viewport_vect)
	aspect_ratio_readout.text = ratio_labels[aspect_ratio_index]
	menu_buttons = ["ASPECT RATIO","FULLSCREEN","BACK"]
	menu_labels = [aspect_ratio,full_screen,back]

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
			"ASPECT RATIO":
				if(aspect_ratio_index < aspect_ratios.size() -1):
					aspect_ratio_index += 1
				else:
					aspect_ratio_index = 0 
				aspect_ratio_readout.text = ratio_labels[aspect_ratio_index]
				get_viewport().content_scale_size = aspect_ratios[aspect_ratio_index]
				parent_menu.play_sound(load("res://audio/effects/bell_quicker.ogg"))
			"FULLSCREEN":
				if(get_viewport().get_mode() == 4):
					get_viewport().mode = 2
				else:
					get_viewport().mode = 4
				parent_menu.play_sound(load("res://audio/effects/bell_quicker.ogg"))
			"BACK":
				queue_free()
				parent_menu.set_active()
				parent_menu.play_sound(load("res://audio/effects/brush_snare.ogg"))
	elif(Input.is_action_just_pressed("action_2")):
		queue_free()
		parent_menu.set_active()
		parent_menu.play_sound(load("res://audio/effects/brush_snare.ogg"))

func set_active():
	active = true
	visible = true

func set_inactive():
	active = false
	visible = false

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
				label.text = menu_buttons[index]
			index = index + 1
		handle_control()
	elif(modulate.a == 1.0):
		active = true
	
