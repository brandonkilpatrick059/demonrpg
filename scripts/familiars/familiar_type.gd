class_name FamiliarType extends Node

var type_name: String = "HOMUNCULUS"
@export var name_text : Text = null
@export var description_1_text : Text = null
@export var description_2_text : Text = null

func apply_to_pkg(buff_holder : Familiar, pkg : BattlePkg) -> BattlePkg:
	return pkg

func get_type_name() -> String:
	return type_name

func get_type_name_text() -> String:
	return name_text.get_text("english")

func get_description_1() -> String:
	return description_1_text.get_text("english")

func get_description_2() -> String:
	return description_2_text.get_text("english")
