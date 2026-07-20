class_name BattleAction extends Node

@export var opponent_choice_weight : float = 0.0

enum TargetType {NO_TARGET,SELF,ANY_ALLY,ANY_OPPONENT,
ALL_ALLIES,ALL_OPPONENTS,ALL,ANY,ANY_BUT_SELF,ANY_DEAD}

var action_name : String = "blank_action"
var target_type : TargetType = TargetType.NO_TARGET

func get_choice_weight()->float:
	return opponent_choice_weight

func get_target_type() -> TargetType:
	return target_type

func get_action_name() -> String:
	return action_name

func clean_up():
	pass

func action_process(actor : Familiar, targets : Array[Familiar]):
	pass
