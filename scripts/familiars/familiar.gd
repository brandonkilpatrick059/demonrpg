class_name Familiar extends Node

#STATS
@export var familiar_name : String = ""
@export var max_hp : int = 1
@export var current_hp : int = 1
@export var attack : int = 1
@export var defense : int = 1
@export var speed : int = 1
@export var magic : int = 1

@export var level : int = 1
@export var experience : int = 0

var actions : Array[BattleAction] = []

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

@onready var actions_parent : Node = $actions

var hostile : bool = false
var dead : bool = false

func _ready() -> void:
	for action_node in actions_parent.get_children():
		actions.append(action_node)

func get_max_hp() -> int:
	return max_hp

func is_hostile():
	return hostile

func mark_hostile():
	hostile = true

func mark_friendly():
	hostile = false

func set_max_hp(num : int):
	max_hp = num

func get_current_hp() -> int:
	return current_hp

func set_current_hp(num : int):
	current_hp = num

func is_dead():
	return dead

func kill():
	sprite.play("dead")
	dead = true

func get_attack() -> int:
	return attack

func set_attack(num : int):
	attack = num

func get_defense() -> int:
	return defense

func set_defense(num : int):
	defense = num

func set_familiar_name (in_name : String):
	familiar_name = in_name

func get_familiar_name() -> String:
	return familiar_name

func get_speed() -> int:
	return speed

func set_speed(num : int):
	speed = num

func get_magic() -> int:
	return magic

func set_magic(num : int):
	magic = num

func get_actions():
	return actions
