extends BattleAction

@export var summon_packed_scenes : Array[PackedScene]
@export var attack_scale : float = 0.0
@export var defense_scale : float = 0.0
@export var magic_scale : float = 0.0
@export var speed_scale : float = 0.0
@export var max_hp_scale : float = 0.0

var announced_summon : bool = false
var made_summon : bool = false

var summon : Familiar = null

var battle_sys_ref : BattleSystemManager

var announcment_english : String = "[TEAM][ACTOR] summons [SUMMON]"

func get_announcement(actor : Familiar, summon_name : String) -> String:
	var ret_string = announcment_english.replace("[ACTOR]",actor.get_familiar_name())
	var team : String = ""
	if (actor.is_hostile()):
		team = hostile_english
	else:
		team = friendly_english
	ret_string = ret_string.replace("[TEAM]",team)
	ret_string = ret_string.replace("[SUMMON]",summon_name)
	return ret_string

func _ready() -> void:
	action_name = "SUMMON"
	target_type = TargetType.NO_TARGET
	damage_type = DamageType.NONE
	energy_cost = 2

func clean_up():
	announced_summon = false
	made_summon = false

func get_summary(actor : Familiar)-> String:
	var summary : String = ""
	summary = str(summary,get_action_name())
	summary = str(summary,"-[color=white]SUMMONS A SERVANT")
	return summary

func visual_effects(actor : Familiar):
	actor.play_one_shot_animation("magic")
	battle_sys_ref.play_sound(load("res://audio/effects/evil_eye.ogg"))

func exit_action():
	battle_sys_ref.start_wait_timer(0.5)
	battle_sys_ref.get_next_action()
	clean_up()

func action_process(actor : Familiar, targets : Array[Familiar]):
	battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
	var num_summons = summon_packed_scenes.size() - 1
	var chosen_packed_scene : PackedScene = summon_packed_scenes[randi_range(0,num_summons)]
	summon = chosen_packed_scene.instantiate()
	if(!announced_summon):
		var announcement : String = get_announcement(actor,summon.get_familiar_name())
		battle_sys_ref.play_messages([announcement])
		announced_summon = true
	if(!made_summon):
		battle_sys_ref.start_wait_timer(0.5)
		visual_effects(actor)
		
		if(magic_scale > 0):
			summon.set_magic(actor.get_magic() * magic_scale)
		if(attack_scale > 0):
			summon.set_attack(actor.get_magic() * attack_scale)
		if(defense_scale > 0):
			summon.set_defense(actor.get_magic() * defense_scale)
		if(speed_scale > 0):
			summon.set_speed(actor.get_magic() * speed_scale)
		if(max_hp_scale > 0):
			var scaled_hp : int = actor.get_magic() * max_hp_scale
			summon.set_max_hp(scaled_hp)
			summon.set_current_hp(scaled_hp)
		var is_hostile = actor.is_hostile()
		summon.set_active()
		battle_sys_ref.add_familiar(summon,is_hostile)
		made_summon = true
	else:
		exit_action()
