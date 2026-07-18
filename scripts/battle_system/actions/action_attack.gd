extends BattleAction

var announced_attack : bool = false

var battle_sys_ref : BattleSystemManager

var friendly_english : String = "your "
var hostile_english : String = "hostile "
var announcment_english : String = "[TEAM][ACTOR] attacks [TEAM2][TARGET]"

func get_announcement(actor : Familiar, target : Familiar) -> String:
	var ret_string = announcment_english.replace("[ACTOR]",actor.get_familiar_name())
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
	action_name = "ATTACK"
	target_type = TargetType.ANY_OPPONENT

func clean_up():
	announced_attack = false

func action_process(actor : Familiar, targets : Array[Familiar]):
	battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
	if(!announced_attack):
		var announcement : String = get_announcement(actor,targets[0])
		battle_sys_ref.play_messages([announcement])
		announced_attack = true
	else:
		battle_sys_ref.start_wait_timer(1.0)
		battle_sys_ref.get_next_action()
		clean_up()
