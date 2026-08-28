extends BattleAction

var announced_defense : bool = false
var made_defense : bool = false

var announcment_english : String = "[TEAM][ACTOR] shields [TEAM][TARGET]"
var announcment_english_reflexive : String = "[TEAM][ACTOR] shields itself"

var battle_sys_ref : BattleSystemManager

func get_announcement(actor : Familiar, target : Familiar) -> String:
	var announcement : String = announcment_english
	if(actor == target):
		announcement = announcment_english_reflexive
	var ret_string = announcement.replace("[ACTOR]",actor.get_familiar_name())
	ret_string = ret_string.replace("[TARGET]",target.get_familiar_name())
	var team : String = ""
	if (actor.is_hostile()):
		team = hostile_english
	else:
		team = friendly_english
	ret_string = ret_string.replace("[TEAM]",team)
	return ret_string

func get_summary(actor : Familiar)-> String:
	var summary : String = ""
	summary = str(summary,str(summary,get_action_name()))
	summary = str(summary,"-[color=white]SHIELDS SELF FOR ")
	var half_damage = get_half_magic(actor)
	if(half_damage == 0):
		half_damage = 1
	summary = str(summary,get_min_max_string(half_damage,half_damage+half_damage))
	summary = str(summary,str("[color=darkred] PHYSICAL DAMAGE [/color]"))
	return summary

func _ready() -> void:
	action_name = "SHIELD"
	target_type = TargetType.SELF

func clean_up():
	made_defense = false
	announced_defense = false

func get_half_magic(actor : Familiar) -> int:
	return (actor.get_magic() / 2)

func action_process(actor : Familiar, targets : Array[Familiar]):
	battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
	if(not announced_defense):
		if(targets[0] != null):
			var announcement : String = get_announcement(actor,targets[0])
			battle_sys_ref.play_messages([announcement])
			announced_defense = true
		else:
			battle_sys_ref.get_next_action()
			clean_up()
	elif(not made_defense):
		var target : Familiar = targets[0]
		var defense_buff = load("res://battle/actions/buffs/defend_buff.tscn").instantiate()
		var half_magic : int = get_half_magic(actor)
		var damage_reduction : int = half_magic + randi_range(0,half_magic)
		if(damage_reduction == 0):
			damage_reduction = 1
		defense_buff.set_damage_reduction(damage_reduction)
		target.add_battle_buff(defense_buff)
		actor.play_one_shot_animation("magic")
		var battle_sys_ref : BattleSystemManager
		battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
		battle_sys_ref.play_sound(load("res://audio/effects/bell_last.ogg"))
		battle_sys_ref.play_sound(load("res://audio/effects/evil_eye.ogg"))
		made_defense = true
	else:
		battle_sys_ref.start_wait_timer(0.5)
		battle_sys_ref.get_next_action()
		clean_up()
