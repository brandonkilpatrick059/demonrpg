extends Node2D

@onready var master : Label = $menu/master
@onready var effects : Label = $menu/effects
@onready var music : Label = $menu/music
@onready var back : Label = $menu/back

var selected_index : int = 0

var db_step = 2
var bottom_volume = -60
var scroll_step_time = 0.05

var menu_buttons : Array[String] = []
var menu_labels : Array[Label] = []
var volume_bars : Array[HPGauge] = []

var transition_to_scene : PackedScene = null

var active : bool = false
var parent_menu : Node = null

func set_parent_menu(menu : Node):
	parent_menu = menu

func _ready() -> void:
	menu_buttons = ["MASTER","EFFECTS","MUSIC","BACK"]
	menu_labels = [master,effects,music,back]
	volume_bars = [$menu/hp_gauge,$menu/hp_gauge2,$menu/hp_gauge3]

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
	elif(Input.is_action_pressed("right")):
		if($scroll_step_timer.is_stopped()):
			if selected_index < menu_buttons.size() - 1:
				var raise_volume : bool = true
				adjust_bus_volume(selected_index,raise_volume)
	elif(Input.is_action_pressed("left")):
		if($scroll_step_timer.is_stopped()):
			if selected_index < menu_buttons.size() - 1:
				var raise_volume : bool = true
				var lower_volume : bool = not raise_volume
				adjust_bus_volume(selected_index,lower_volume)
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
				parent_menu.set_active()

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

func adjust_bus_volume(bus : int, raise : bool = true):
	if($scroll_step_timer.is_stopped()):
		var volume : float = AudioServer.get_bus_volume_db(bus)
		if(not raise and volume > bottom_volume):
			AudioServer.set_bus_volume_db(bus, volume - db_step)
			$AudioStreamPlayer.stream = load("res://audio/effects/bell_quicker.ogg")
			$AudioStreamPlayer.play()
		elif(volume != 0.0):
			AudioServer.set_bus_volume_db(bus, volume + db_step)
			$AudioStreamPlayer.stream = load("res://audio/effects/bell_quicker.ogg")
			$AudioStreamPlayer.play()
		#ensure values range is not exceeded
		#if(volume > 0.0):
			#AudioServer.set_bus_volume_db(bus, 0.0)
		#elif(volume < bottom_volume):
			#AudioServer.set_bus_volume_db(bus, bottom_volume)
		$scroll_step_timer.start(scroll_step_time)

func update_volume_bars():
	var index : int = 0
	for gauge : HPGauge in volume_bars:
		var current_vol = AudioServer.get_bus_volume_db(index)
		var fraction = (bottom_volume - current_vol)/bottom_volume
		if(fraction < 0.05):
			fraction = 0.0
		gauge.set_gauge(fraction)
		index = index + 1

func _physics_process(delta: float) -> void:
	var camera : Camera2D = get_tree().get_first_node_in_group("camera")
	global_position = camera.get_screen_center_position()
	if(active):
		var index = 0
		for label in menu_labels:
			if(index == selected_index):
				label.modulate = Color(1.0,0,0.75,1.0)
				if(index != menu_labels.size() - 1):
					label.text = str(str("<-",menu_buttons[selected_index]),"->")
			else:
				label.modulate = Color(1,1,1,1)
				label.text = menu_buttons[index]
			index = index + 1
		handle_control()
		update_volume_bars()
	elif(transition_to_scene != null):
		var fade_black = get_tree().get_first_node_in_group("fade_black")
		if(fade_black.modulate.a == 1.0):
			get_tree().change_scene_to_packed(transition_to_scene)
	elif(modulate.a == 1.0):
		active = true
	
