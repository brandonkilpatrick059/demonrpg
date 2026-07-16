class_name BattleActionMenu extends Node2D

@onready var energy_bar : AnimatedSprite2D = $energy_bar
@onready var num_act_tab : AnimatedSprite2D = $num_act_tab

var tabs : Array[ActionMenuTab] = []

func _ready() -> void:
	#set up action tabs
	for child in $tabs.get_children():
		tabs.append(child)
		
	#energy bar and action number tabs are off by default
	energy_bar.visible = false
	num_act_tab.visible = false

func set_actions(actions : Array[BattleAction]):
	var index = 0
	for tab in tabs:
		if(index < actions.size()):
			tabs[index].set_active()
			tabs[index].set_tab(actions[index])
		else:
			tabs[index].set_inactive()
