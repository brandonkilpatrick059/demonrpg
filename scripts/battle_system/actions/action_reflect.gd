extends BattleAction

var announced_defense : bool = false
var made_defense : bool = false

var friendly_english : String = "your "
var hostile_english : String = "hostile "
var announcment_english : String = "[TEAM][ACTOR] defends [TEAM][TARGET]"
var announcment_english_reflexive : String = "[TEAM][ACTOR] defends itself"

var battle_sys_ref : BattleSystemManager

func get_announcement(actor : Familiar, target : Familiar) -> String:
	var announcement : String = announcment_english
	if(actor == target):
		announcement = announcment_english_reflexive
	var ret_string = announcement.replace("[ACTOR]",actor.get_familiar_name())
	ret_string = ret_string.replace("[TARGET]",target.get_familiar_name())
	var team : String = ""
	var team2 : String = ""
	if (actor.is_hostile()):
		team = hostile_english
	else:
		team = friendly_english
	ret_string = ret_string.replace("[TEAM]",team)
	return ret_string

func _ready() -> void:
	action_name = "REFLECT"
	target_type = TargetType.ANY_ALLY
	energy_cost = 2

func clean_up():
	made_defense = false
	announced_defense = false

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
		var reflect_buff = load("res://battle/actions/buffs/reflect_buff.tscn").instantiate()
		target.add_battle_buff(reflect_buff)
		actor.play_one_shot_animation("defend")
		var battle_sys_ref : BattleSystemManager
		battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
		battle_sys_ref.play_sound(load("res://audio/effects/bell_last.ogg"))
		#pay_energy_cost(actor)
		made_defense = true
	else:
		battle_sys_ref.start_wait_timer(1.0)
		battle_sys_ref.get_next_action()
		clean_up()
