class_name FamiliarSlot extends Node2D

@export var select_arrow : Node
@export var upgrade_label : Label

func show_select_arrow():
	select_arrow.visible = true

func hide_select_arrow():
	select_arrow.visible = false
	hide_upgrade_label()

func show_upgrade_label(set_text : String):
	upgrade_label.text = set_text
	upgrade_label.visible = true

func hide_upgrade_label():
	upgrade_label.visible = false
