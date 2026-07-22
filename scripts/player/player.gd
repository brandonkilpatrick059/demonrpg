class_name Player extends Node2D

var familiar_team : Array[Familiar] = []
var stored_familiars : Array[Familiar] = []
@export var pentacle_charms : int = 0

func get_familiars_team() -> Array[Familiar]:
	return familiar_team

func set_familiars_team(in_team : Array[Familiar]):
	familiar_team.clear()
	familiar_team.append_array(in_team)

func get_stored_familiars() -> Array[Familiar]:
	return stored_familiars

func set_stored_familiars(in_familiars : Array[Familiar]):
	stored_familiars.clear()
	stored_familiars.append_array(in_familiars)

func get_pentacle_charms() -> int:
	return pentacle_charms

func set_pentacle_charms(num : int):
	pentacle_charms = num
