class_name BattleAction extends Node

enum TargetType {NO_TARGET,SELF,ANY_ALLY,ANY_OPPONENT,ALL_ALLIES,ALL_OPPONENTS,
HALF_ALLIES,HALF_OPPONENTS,ALL,ANY,ANY_DEAD}

@export var action_name : String = "blank_action"
@export var type : TargetType = TargetType.NO_TARGET

func get_type() -> TargetType:
	return type

func get_action_name() -> String:
	return action_name

func run_action(actor : Familiar, targets : Array[Familiar]):
	pass
