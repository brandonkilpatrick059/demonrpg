class_name Familiar extends Node

#STATS
@export var max_hp : int = 1
@export var current_hp : int = 1
@export var attack : int = 1
@export var defense : int = 1
@export var speed : int = 1
@export var magic : int = 1

@export var level : int = 1
@export var exp : int = 0

@export var actions : Array[Battle_Action] = []

@export var battle_sprite : AnimatedSprite2D

func get_max_hp() -> int:
	return max_hp

func set_max_hp(num : int):
	max_hp = num

func get_current_hp() -> int:
	return current_hp

func set_current_hp(num : int):
	current_hp = num

func get_attack() -> int:
	return attack

func set_attack(num : int):
	attack = num

func get_defense() -> int:
	return defense

func set_defense(num : int):
	defense = num

func get_speed() -> int:
	return speed

func set_speed(num : int):
	speed = num

func get_magic() -> int:
	return magic

func set_magic(num : int):
	magic = num

func get_battle_sprite() -> AnimatedSprite2D:
	return battle_sprite

func set_battle_sprite(sprite : AnimatedSprite2D):
	battle_sprite = sprite
