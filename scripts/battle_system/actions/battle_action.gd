class_name BattleAction extends Node

@export var opponent_choice_weight : float = 0.0
@export var summary : Text

enum TargetType {NO_TARGET,SELF,ANY_ALLY,ANY_OPPONENT,TWO_ADJACENT_OPPONENT,
ALL_ALLIES,ALL_OPPONENTS,ALL,ANY,ANY_BUT_SELF,ANY_DEAD}

enum DamageType {NONE,PHYSICAL,MAGIC}

var action_name : String = "blank_action"
var target_type : TargetType = TargetType.NO_TARGET
var energy_cost : int = 0
var damage_type : DamageType = DamageType.NONE

var slain_english : String = "[TEAM][TARGET] is slain"
var friendly_english : String = "your "
var hostile_english : String = "hostile "
var display_color : String = ""

func get_slain_message(actor : Familiar, target : Familiar) -> String:
	var ret_string = slain_english.replace("[TARGET]",target.get_familiar_name())
	var team : String = ""
	if (target.is_hostile()):
		team = hostile_english
	else:
		team = friendly_english
	ret_string = ret_string.replace("[TEAM]",team)
	return ret_string

func get_summary(actor : Familiar) -> String:
	return ""

func get_min_max_string(min : int, max : int) -> String:
	var concat_str = ""
	concat_str = str("[color=yellow]",min)
	concat_str = str(concat_str,"[/color]")
	if(min != max):
		concat_str = str(concat_str,"[color=white] TO ")
		concat_str = str(concat_str,"[/color]")
		concat_str = str(concat_str,str("[color=yellow]",max))
		concat_str = str(concat_str,"[/color]")
	return concat_str

func get_choice_weight() -> float:
	return opponent_choice_weight

func get_display_color() -> String:
	return display_color

func get_damage_type() -> DamageType:
	return damage_type

func get_energy_cost() -> int:
	return energy_cost

func get_target_type() -> TargetType:
	return target_type

func get_action_name() -> String:
	return action_name


func kill_target(actor: Familiar, target : Familiar):
	target.kill()
	if(not target.is_in_group("player_familiar")):
		var battle_sys_ref : BattleSystemManager
		battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
		battle_sys_ref.play_sound(load("res://audio/effects/die.ogg"))
		var slain_message : String = get_slain_message(actor, target)
		battle_sys_ref.play_messages([slain_message])

func pay_energy_cost(actor : Familiar):
	if(energy_cost > 0):
		var current_energy = actor.get_current_energy()
		actor.use_energy(energy_cost)

func clean_up():
	pass

func action_process(actor : Familiar, targets : Array[Familiar]):
	pass
