extends BattleAction

var announced_magic : bool = false
var printed_level : bool = false
var cast_magic : bool = false

var announcment_english : String = "[TEAM][ACTOR] scries on [TEAM2][TARGET]"
var level_english : String = "[TEAM2][TARGET] is Level [LEVEL]"
var hp_english : String = "[color=[COLOR]][CURRENT]/[MAX][/color] Health"

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

func get_level(target : Familiar) -> String:
	var ret_string : String = level_english
	ret_string = ret_string.replace("[TARGET]",target.get_familiar_name())
	var team2 : String = hostile_english
	ret_string = ret_string.replace("[TEAM2]",team2)
	var level : String = str(target.get_level())
	ret_string = ret_string.replace("[LEVEL]",level)
	return ret_string

func get_health(target : Familiar) -> String:
	var ret_string : String = hp_english
	var current : String = str(target.get_current_hp())
	var max : String = str(target.get_max_hp())
	var color : String = ""
	var ratio : float = float(current)/float(max)
	if(ratio < 0.33):
		color = "red"
	elif(ratio < 0.66):
		color = "yellow"
	else:
		color = "green"
	ret_string = ret_string.replace("[CURRENT]",current)
	ret_string = ret_string.replace("[MAX]",max)
	ret_string = ret_string.replace("[COLOR]",color)
	return ret_string

func _ready() -> void:
	action_name = "SCRY"
	target_type = TargetType.ANY_OPPONENT

func clean_up():
	cast_magic = false
	announced_magic = false
	printed_level = false

func exit_action():
	battle_sys_ref.start_wait_timer(1.0)
	battle_sys_ref.get_next_action()
	clean_up()

func get_summary(actor : Familiar)-> String:
	var summary : String = ""
	summary = str(summary,str(summary,get_action_name()))
	summary = str(summary,"-[color=white]SHOWS[/color] [color=yellow]ENERGY AND HEALTH[/color][color=darkred][/color][color=white] FOR ")
	var base : int = get_base()
	var max : int = get_divided_magic(actor)
	summary = str(summary,get_min_max_string(base,base + get_divided_magic(actor)))
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
			var messages : Array[String] = [announcement]
			battle_sys_ref.play_messages(messages)
			announced_magic = true
		else:
			exit_action()
	elif(not cast_magic):
		var target : Familiar = targets[0]
		var scry_buff = load("res://battle/actions/buffs/scry_buff.tscn").instantiate()
		var divided_magic = get_divided_magic(actor)
		var extra_turns : int = randi_range(0,divided_magic)
		var lifetime : int = get_base() + extra_turns
		scry_buff.set_lifetime(lifetime)
		scry_buff.set_target(target)
		target.add_battle_buff(scry_buff)
		actor.play_one_shot_animation("magic")
		var battle_sys_ref : BattleSystemManager
		battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
		battle_sys_ref.play_sound(load("res://audio/effects/evil_eye.ogg"))
		
		if(targets[0] != null && targets[0].is_hostile()):
			var messages : Array[String] = []
			var level_string : String = get_level(targets[0])
			var hp_string : String = get_health(targets[0])
			messages.append_array([level_string,hp_string])
			battle_sys_ref.play_messages(messages)
		cast_magic = true
	#elif(not printed_level):
		#
		#printed_level = true
	else:
		exit_action()
