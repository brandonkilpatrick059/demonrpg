extends BattleAction

var announced_feed : bool = false
var commenced_feed : bool = false
var comment_feed : bool = false
var announced_failure : bool = false

var battle_sys_ref : BattleSystemManager

var announcment_english : String = "[TEAM][ACTOR] wants to eat [TEAM2][TARGET]..."
var success_english : String = "[TEAM][ACTOR] eats [TEAM2][TARGET]"
var failure_english : String = "but [TEAM][ACTOR] cannot eat [TEAM2][TARGET]"
var comment_english : String = "[TEAM][ACTOR] grows more powerful..."

var feed_succeeded : bool = false

var success_message : String = ""

func get_summary(actor : Familiar)-> String:
	var summary : String = "[color=red]"
	summary = str(summary,get_action_name())
	summary = str(summary,"[/color]-[color=white]ATTEMPT TO CONSUME TARGET'S [/color]")
	summary = str(summary,str("[color=darkred]POWER [/color]"))
	return summary

func get_announcement(actor : Familiar, target : Familiar) -> String:
	var ret_string = announcment_english.replace("[ACTOR]",actor.get_familiar_name())
	ret_string = ret_string.replace("[TARGET]",target.get_familiar_name())
	var team : String = ""
	var team2 : String = ""
	if (actor.is_hostile()):
		team = hostile_english
	else:
		team = friendly_english
	if (target.is_hostile()):
		team2 = hostile_english
	else:
		team2 = friendly_english
	ret_string = ret_string.replace("[TEAM]",team)
	if(not target.is_in_group("player_familiar")):
		ret_string = ret_string.replace("[TEAM2]",team2)
	else:
		ret_string = ret_string.replace("[TEAM2]","")
	return ret_string

func determine_feed_success(actor : Familiar, target : Familiar):
	success_message = get_comment_message(actor)
	if(target.is_dead()):
		feed_succeeded = true
	elif(target.is_in_group("player_familiar")):
		feed_succeeded = false
	else:
		var actor_roll_total : int = 0
		actor_roll_total = actor_roll_total + actor.get_current_hp()
		actor_roll_total = actor_roll_total + actor.get_attack()
		actor_roll_total = actor_roll_total + actor.get_defense()
		actor_roll_total = actor_roll_total + actor.get_magic()
		actor_roll_total = actor_roll_total + actor.get_speed()
		var target_roll_total : int = 0
		target_roll_total = target_roll_total + target.get_current_hp()
		target_roll_total = target_roll_total + target.get_attack()
		target_roll_total = target_roll_total + target.get_defense()
		target_roll_total = target_roll_total + target.get_magic()
		target_roll_total = target_roll_total + target.get_speed()
		
		var actor_roll : int = randi_range(1,actor_roll_total)
		if(actor_roll > target_roll_total):
			feed_succeeded = true
		else:
			feed_succeeded = false

func get_success_message(actor : Familiar, target : Familiar) -> String:
	var ret_string = success_english.replace("[ACTOR]",actor.get_familiar_name())
	ret_string = success_english.replace("[TARGET]",target.get_familiar_name())
	var team : String = ""
	var team2 : String = ""
	if (actor.is_hostile()):
		team = hostile_english
	else:
		team = friendly_english
	if (target.is_hostile()):
		team2 = hostile_english
	else:
		team2 = friendly_english
	ret_string = ret_string.replace("[TEAM]",team)
	ret_string = ret_string.replace("[TEAM2]",team2)
	return ret_string

func get_failure_message(actor : Familiar, target : Familiar) -> String:
	var ret_string = failure_english.replace("[ACTOR]",actor.get_familiar_name())
	ret_string = ret_string.replace("[TARGET]",target.get_familiar_name())
	var team : String = ""
	var team2 : String = ""
	if (actor.is_hostile()):
		team = hostile_english
	else:
		team = friendly_english
	if (target.is_hostile()):
		team2 = hostile_english
	else:
		team2 = friendly_english
	ret_string = ret_string.replace("[TEAM]",team)
	if(not target.is_in_group("player_familiar")):
		ret_string = ret_string.replace("[TEAM2]",team2)
	else:
		ret_string = ret_string.replace("[TEAM2]","")
	return ret_string

func get_comment_message(actor : Familiar) -> String:
	var ret_string = comment_english.replace("[ACTOR]",actor.get_familiar_name())
	var team : String = ""
	if (actor.is_hostile()):
		team = hostile_english
	else:
		team = friendly_english
	ret_string = ret_string.replace("[TEAM]",team)
	return ret_string

func _ready() -> void:
	action_name = "FEED"
	display_color = "red"
	target_type = TargetType.ANY_BUT_SELF
	energy_cost = 0

func clean_up():
	announced_feed = false
	commenced_feed = false
	comment_feed  = false
	announced_failure = false

func visual_effects(actor : Familiar, target : Familiar):
	var feed_effect = load("res://battle/effects/feed_effect.tscn").instantiate()
	battle_sys_ref.add_child(feed_effect)
	feed_effect.set_kill_node(target)
	feed_effect.global_position = target.global_position
	battle_sys_ref.play_sound(load("res://audio/effects/feed.ogg"))

func exit_action():
	battle_sys_ref.start_wait_timer(0.5)
	battle_sys_ref.get_next_action()
	clean_up()

func action_process(actor : Familiar, targets : Array[Familiar]):
	battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
	if(not announced_feed):
		if(targets[0] != null):
			var announcement : String = get_announcement(actor,targets[0])
			battle_sys_ref.play_messages([announcement])
			determine_feed_success(actor,targets[0])
			announced_feed = true
		else:
			exit_action()
	elif(not commenced_feed && feed_succeeded):
		battle_sys_ref.start_wait_timer(0.5)
		var target : Familiar = targets[0]
		if(not target.is_dead()):
			target.kill()
		actor.consume_familiar(target)
		visual_effects(actor,target)
		var heal_for = target.get_max_hp() / 2
		var actor_hp = actor.get_current_hp()
		actor_hp = actor_hp + heal_for
		actor.set_current_hp(actor_hp)
		if(actor.get_current_hp() > actor.get_max_hp()):
			actor.set_current_hp(actor.get_max_hp())
		commenced_feed = true
	elif(not announced_failure && not feed_succeeded):
		var comment : String = get_failure_message(actor,targets[0])
		battle_sys_ref.play_messages([comment])
		announced_failure = true
	elif(not comment_feed && feed_succeeded):
		var comment : String = success_message
		battle_sys_ref.play_messages([comment])
		comment_feed = true
	else:
		exit_action()
