class_name BattleBuff extends Node2D

var active : bool = true

var inactive_after_rounds : int = 1
var rounds_active : int = 0

var type : String = "blank"

var status_effect : bool = false
var cured_by_heal : bool = false

func is_status_effect() -> bool:
	return status_effect

func is_cured_by_heal() -> bool:
	return cured_by_heal

func is_active():
	return active

func get_type():
	return type

func stack(stack_buff : BattleBuff):
	return

func add_round_active() : 
	rounds_active = rounds_active + 1

func check_round_lifetime():
	if(rounds_active >= inactive_after_rounds):
		queue_free()

func apply_status_effect():
	pass

func apply_to_pkg(buff_holder : Familiar, pkg : BattlePkg) -> BattlePkg:
	return pkg
