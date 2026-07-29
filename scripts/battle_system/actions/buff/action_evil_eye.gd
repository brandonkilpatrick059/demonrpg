extends BattleAction

var announced_magic : bool = false
var cast_magic : bool = false

var announcment_english : String = "[TEAM][ACTOR] curses [TEAM2][TARGET]"

var battle_sys_ref : BattleSystemManager

func get_announcement(actor : Familiar, target : Familiar) -> String:
	var announcement : String = announcment_english
	var ret_string = announcement.replace("[ACTOR]",actor.get_familiar_name())
	ret_string = ret_string.replace("[TARGET]",target.get_familiar_name())
	var team : String = ""
	var team2 : String = ""
	if (actor.is_hostile()):
		team = hostile_english
		team2 = friendly_english
	else:
		team = friendly_english
		team2 = hostile_english
	ret_string = ret_string.replace("[TEAM]",team)
	if(not target.is_in_group("player_familiar")):
		ret_string = ret_string.replace("[TEAM2]",team2)
	else:
		ret_string = ret_string.replace("[TEAM2]","")
	return ret_string

func _ready() -> void:
	action_name = "EVIL EYE"
	target_type = TargetType.ANY_OPPONENT

func clean_up():
	cast_magic = false
	announced_magic = false

func exit_action():
	battle_sys_ref.start_wait_timer(1.0)
	battle_sys_ref.get_next_action()
	clean_up()

func get_summary(actor : Familiar)-> String:
	var summary : String = ""
	summary = str(summary,str(summary,get_action_name()))
	summary = str(summary,"-[color=yellow]x2[/color][color=darkred] PHYSICAL DAMAGE [/color][color=white] FOR ")
	var base : int = get_base()
	var max : int = get_divided_magic(actor)
	summary = str(summary,str(base," TO "))
	summary = str(summary,str(base + get_divided_magic(actor)))
	summary = str(summary,str("[color=white] TURNS [/color]"))
	return summary

func get_base() -> int:
	return 2

func get_divided_magic(actor : Familiar) -> int:
	return actor.get_magic() / 5

func action_process(actor : Familiar, targets : Array[Familiar]):
	battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
	if(not announced_magic):
		if(targets[0] != null):
			var announcement : String = get_announcement(actor,targets[0])
			battle_sys_ref.play_messages([announcement])
			announced_magic = true
		else:
			exit_action()
	elif(not cast_magic):
		var target : Familiar = targets[0]
		var evil_eye_buff = load("res://battle/actions/buffs/evil_eye_buff.tscn").instantiate()
		var divided_magic = get_divided_magic(actor)
		var extra_turns : int = randi_range(0,divided_magic)
		var lifetime : int = get_base() + extra_turns
		evil_eye_buff.set_lifetime(lifetime)
		target.add_battle_buff(evil_eye_buff)
		actor.play_one_shot_animation("magic")
		var battle_sys_ref : BattleSystemManager
		battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
		battle_sys_ref.play_sound(load("res://audio/effects/evil_eye.ogg"))
		cast_magic = true
	else:
		exit_action()
