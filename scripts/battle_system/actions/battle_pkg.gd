class_name BattlePkg extends Node

var actor : Familiar
var targets : Array[Familiar] = []
var damage_type : BattleAction.DamageType = BattleAction.DamageType.NONE

var final_damages : Array[int] = [0]

func set_final_damages(num : Array[int]):
	final_damages.clear()
	final_damages.append_array(num)

func get_final_damages() -> Array[int]:
	return final_damages

func set_damage_type(type : BattleAction.DamageType):
	damage_type = type

func get_damage_type() -> BattleAction.DamageType:
	return damage_type

func get_actor():
	return actor

func set_actor(in_actor : Familiar):
	actor = in_actor

func set_targets(in_familiars : Array[Familiar]):
	targets.clear()
	targets.append_array(in_familiars)

func get_targets() -> Array[Familiar]:
	return targets
