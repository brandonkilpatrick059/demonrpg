class_name BattlePkg extends Node

var actor : Familiar
var targets : Array[Familiar] = []

var final_damage : int = 0

func set_final_damage(num : int):
	final_damage = num

func get_final_damage() -> int:
	return final_damage

func get_actor():
	return actor

func set_actor(in_actor : Familiar):
	actor = in_actor

func set_targets(in_familiars : Array[Familiar]):
	targets.clear()
	targets.append_array(in_familiars)

func get_targets() -> Array[Familiar]:
	return targets
