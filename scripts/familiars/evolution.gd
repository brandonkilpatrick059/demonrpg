class_name Evolution extends Node

@export var path_text : Text

@export var new_base_path : String = ""

#stat bonuses
@export var plus_attack : int = 0
@export var plus_defense : int = 0
@export var plus_magic : int = 0
@export var plus_speed : int = 0
@export var plus_num_acts : int = 0
@export var plus_max_hp : int = 0

func get_path_text() -> String:
	return path_text.get_text("english")
	
func get_evolved_familiar(familiar : Familiar) -> Familiar:
	var new_base : Familiar = load(new_base_path).instantiate()
	var attack : int = familiar.get_attack()
	var defense : int = familiar.get_defense()
	var magic : int = familiar.get_magic()
	var speed : int = familiar.get_speed()
	var num_actions : int = familiar.get_num_actions()
	var max_hp : int =familiar.get_max_hp()
	var sigil : String = familiar.get_sigil()
	attack = attack + plus_attack
	defense = defense + plus_defense
	magic = magic + plus_magic
	speed = speed + plus_speed
	max_hp = max_hp + plus_max_hp
	num_actions = num_actions + plus_num_acts
	new_base.set_attack(attack)
	new_base.set_defense(defense)
	new_base.set_magic(magic)
	new_base.set_speed(speed)
	new_base.set_max_hp(max_hp)
	new_base.set_current_hp(max_hp)
	new_base.set_num_actions(num_actions)
	new_base.set_sigil(sigil)
	return new_base
	
