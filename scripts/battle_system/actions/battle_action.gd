class_name BattleAction extends Node

enum TargetType {NO_TARGET,SELF,ANY_ALLY,ANY_OPPONENT,
ALL_ALLIES,ALL_OPPONENTS,ALL,ANY,ANY_DEAD}

var action_name : String = "blank_action"
var target_type : TargetType = TargetType.NO_TARGET

func get_target_type() -> TargetType:
	return target_type

func get_action_name() -> String:
	return action_name

func clean_up():
	pass

func action_process(actor : Familiar, targets : Array[Familiar]):
	pass
