extends Node2D

@onready var keyboard : Node2D = $keyboard_controls
@onready var controller_xbox : Node2D = $controller_xbox

var selected_index : int = 0

var control_screens : Array[Node] = []

var active : bool = false
var parent_menu : Node = null

func set_parent_menu(menu : Node):
	parent_menu = menu

func _ready() -> void:
	control_screens = [keyboard,controller_xbox]
	active = true

func handle_control():
	if(Input.is_action_just_pressed("right")):
		if selected_index < control_screens.size() - 1:
			selected_index = selected_index + 1
		else:
			selected_index = 0
		$AudioStreamPlayer.stream = load("res://audio/effects/click.ogg")
		$AudioStreamPlayer.play()
	elif(Input.is_action_just_pressed("left")):
		if selected_index > 0:
			selected_index = selected_index - 1
		else:
			selected_index = control_screens.size()-1
		$AudioStreamPlayer.stream = load("res://audio/effects/click.ogg")
		$AudioStreamPlayer.play()
	elif(Input.is_action_just_pressed("action_2")):
		parent_menu.set_active()
		queue_free()

func _physics_process(delta: float) -> void:
	var camera : Camera2D = get_tree().get_first_node_in_group("camera")
	global_position = camera.get_screen_center_position()
	if(active):
		var index = 0
		for screen in control_screens:
			if(index == selected_index):
				screen.visible = true
			else:
				screen.visible = false
			index = index + 1
		handle_control()
	
