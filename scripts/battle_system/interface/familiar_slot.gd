class_name FamiliarSlot extends Node2D

@export var select_arrow : Node
@export var upgrade_label : Label
@export var mini_status : MiniBattleStatus

func show_select_arrow():
	select_arrow.visible = true

func hide_select_arrow():
	select_arrow.visible = false
	hide_mini_status()
	hide_upgrade_label()

func show_mini_status(familiar : Familiar):
	if(not familiar.is_dead()):
		mini_status.set_energy_gauge(familiar.get_current_energy())
		var current_hp : float = float(familiar.get_current_hp())
		var max_hp : float = float(familiar.get_max_hp())
		var fraction : float = current_hp/max_hp
		var no_animation : bool = true
		mini_status.set_hp_gauge(fraction,no_animation)
		mini_status.visible = true

func hide_mini_status():
	mini_status.visible = false

func show_upgrade_label(set_text : String):
	upgrade_label.text = set_text
	upgrade_label.visible = true

func hide_upgrade_label():
	upgrade_label.visible = false
