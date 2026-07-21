class_name BattleAction extends Node

@export var opponent_choice_weight : float = 0.0

enum TargetType {NO_TARGET,SELF,ANY_ALLY,ANY_OPPONENT,
ALL_ALLIES,ALL_OPPONENTS,ALL,ANY,ANY_BUT_SELF,ANY_DEAD}

enum DamageType {NONE,PHYSICAL,MAGIC}

var action_name : String = "blank_action"
var target_type : TargetType = TargetType.NO_TARGET
var energy_cost : int = 0
var damage_type : DamageType = DamageType.NONE

func get_choice_weight() -> float:
	return opponent_choice_weight

func get_damage_type() -> DamageType:
	return damage_type

func get_energy_cost() -> int:
	return energy_cost

func get_target_type() -> TargetType:
	return target_type

func get_action_name() -> String:
	return action_name

func pay_energy_cost(actor : Familiar):
	var current_energy = actor.get_current_energy()
	actor.set_current_energy(current_energy - energy_cost)

func clean_up():
	pass

func action_process(actor : Familiar, targets : Array[Familiar]):
	pass
