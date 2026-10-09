extends Node2D

@onready var audio : Label = $menu/VBoxContainer/audio
@onready var video : Label = $menu/VBoxContainer/video
@onready var back : Label = $menu/VBoxContainer/back

var selected_index : int = 0

var menu_buttons : Array[String] = []
var menu_labels : Array[Label] = []

var transition_to_scene : PackedScene = null

var active : bool = false
var parent_menu : Node = null

func set_parent_menu(menu : Node):
	parent_menu = menu

func _ready() -> void:
	menu_buttons = ["AUDIO","VIDEO","BACK"]
	menu_labels = [audio,video,back]

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
			"AUDIO":
				$AudioStreamPlayer.stream = load("res://audio/effects/bell_full_low.ogg")
				$AudioStreamPlayer.play()
				active = false
			"VIDEO":
				transition_to_scene = load("res://locations/zone_manager_load.tscn")
				$AudioStreamPlayer.stream = load("res://audio/effects/bell_full_low.ogg")
				$AudioStreamPlayer.play()
				active = false
			"BACK":
				queue_free()
	

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
	
