class_name Battle_Action extends Node

enum target_type {NO_TARGET,SELF,ANY_ALLY,ANY_OPPONENT,ALL_ALLIES,ALL_OPPONENTS,
HALF_ALLIES,HALF_OPPONENTS,ALL,ANY,ANY_DEAD}

@export var action_name : String = "blank_action"
@export var type : target_type = target_type.NO_TARGET

func get_type() -> target_type:
	return type

func get_action_name() -> String:
	return action_name

func run_action():
	pass
