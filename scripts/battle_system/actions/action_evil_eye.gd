extends BattleAction

var announced_magic : bool = false
var cast_magic : bool = false

var friendly_english : String = "your "
var hostile_english : String = "hostile "
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
	ret_string = ret_string.replace("[TEAM2]",team2)
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
		var divided_magic = actor.get_magic() / 5
		var extra_turns : int = randi_range(0,divided_magic)
		var lifetime : int = 2 + extra_turns
		evil_eye_buff.set_lifetime(lifetime)
		target.add_battle_buff(evil_eye_buff)
		actor.play_one_shot_animation("magic")
		var battle_sys_ref : BattleSystemManager
		battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
		battle_sys_ref.play_sound(load("res://audio/effects/evil_eye.ogg"))
		cast_magic = true
	else:
		exit_action()
