class_name BattleActionMenu extends Node2D

@onready var background : AnimatedSprite2D = $background
@onready var energy_gauge : AnimatedSprite2D = $energy_bar
@onready var num_act_tab : Sprite2D = $num_act_tab

var tabs : Array[ActionMenuTab] = []

var selected_index : int = 0
var num_actions : int = 0

var active : bool = false

var audio_player := AudioStreamPlayer.new()

var energy : int = 0

func _ready() -> void:
	#set up action tabs
	for child in $tabs.get_children():
		tabs.append(child)

	#action number tabs are off by default
	num_act_tab.visible = false
	
	#TODO: buses and stuff
	add_child(audio_player)

func set_energy_gauge(num : int):
	energy_gauge.frame = num
	energy = num

func get_height():
	return num_actions * 8

func is_active() -> bool:
	return active

func set_active():
	visible = true
	active = true
	update_selected()

func set_inactive():
	visible = false
	active = false

func update_selected():
	var index = 0
	for tab in tabs:
		if(index < num_actions):
			if(index == selected_index):
				tab.set_selected()
			else:
				tab.set_active()
		index = index + 1

func set_actions(actions : Array[BattleAction]):
	selected_index = 0
	num_actions = actions.size()
	var index = 0
	for tab in tabs:
		if(index < actions.size()):
			tabs[index].set_active()
			tabs[index].set_tab(actions[index])
		else:
			tabs[index].set_inactive()
		index = index + 1
	background.frame = actions.size() - 1

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
			if(selected_index < num_actions-1):
				selected_index = selected_index + 1
				audio_player.stream = load("res://audio/effects/click.ogg")
				update_selected()
			else:
				audio_player.stream = load("res://audio/effects/short_bell.ogg")
			audio_player.play()
		elif(Input.is_action_just_pressed("action_1")):
			var chosen_action : BattleAction = tabs[selected_index].get_action()
			if(energy >= chosen_action.get_energy_cost()):
				set_inactive()
				var battle_system : BattleSystemManager
				battle_system = get_tree().get_first_node_in_group("battle_system")
				battle_system.start_target_process(chosen_action)
				audio_player.stream = load("res://audio/effects/bell_first.ogg")
				audio_player.play()
			else:
				audio_player.stream = load("res://audio/effects/short_bell.ogg")
				audio_player.play()
		elif(Input.is_action_just_pressed("action_2")):
			set_inactive()
			var battle_system : BattleSystemManager
			battle_system = get_tree().get_first_node_in_group("battle_system")
			battle_system.reset_show_status()
			audio_player.stream = load("res://audio/effects/click.ogg")
			audio_player.play()

func _physics_process(delta: float) -> void:
	handle_input()
