extends BattleAction

@export var direction : String = "LEFT"

var announced_push : bool = false
var made_push : bool = false

var battle_sys_ref : BattleSystemManager

var announcment_english : String = "[TEAM][ACTOR] pushes [TEAM2][TARGET]"
var announcment_english_first_person : String = "[TEAM][ACTOR] pushes [TEAM2][TARGET]"

func get_announcement(actor : Familiar, target : Familiar) -> String:
	var ret_string = announcment_english.replace("[ACTOR]",actor.get_familiar_name())
	if(actor.is_in_group("player_familiar")):
		ret_string = announcment_english_first_person.replace("[ACTOR]",actor.get_familiar_name())
	ret_string = ret_string.replace("[TARGET]",target.get_familiar_name())
	var team : String = ""
	var team2 : String = ""
	if (actor.is_hostile()):
		team = hostile_english
		team2 = friendly_english
	else:
		team = friendly_english
		team2 = hostile_english
	if(not actor.is_in_group("player_familiar")):
		ret_string = ret_string.replace("[TEAM]",team)
	else:
		ret_string = ret_string.replace("[TEAM]","")
	if(not target.is_in_group("player_familiar")):
		ret_string = ret_string.replace("[TEAM2]",team2)
	else:
		ret_string = ret_string.replace("[TEAM2]","")
	return ret_string

func _ready() -> void:
	action_name = str("PUSH ",direction)
	target_type = TargetType.ANY_OPPONENT
	damage_type = DamageType.NONE

func clean_up():
	announced_push = false
	made_push = false

func get_summary(actor : Familiar)-> String:
	var summary : String = ""
	summary = str(summary,get_action_name())
	summary = str(summary,"-[color=white]PUSHES OPPONENT " )
	summary = str(summary,direction)
	summary = str(summary,"[/color]")
	return summary

func visual_effects(pkg : BattlePkg):
	var actor : Familiar = pkg.get_actor()
	var target : Familiar = pkg.get_targets()[0]
	if(target != null):
		actor.play_one_shot_animation("attack")
		var glow_red_node = load("res://utility/faders/attack_glow_red.tscn").instantiate()
		target.add_child(glow_red_node)
		if(actor.is_hostile()):
			var emerge_node = load("res://utility/faders/fade_in_and_back.tscn").instantiate()
			actor.add_child(emerge_node)
		var attack_effect = load("res://battle/effects/stab_effect.tscn").instantiate()
		target.add_child(attack_effect)
		attack_effect.position = target.position
		battle_sys_ref.play_sound(load("res://audio/effects/hit_2.ogg"))

func get_battle_pkg(actor : Familiar, targets: Array[Familiar]) -> BattlePkg:
	var target : Familiar = targets[0]
	var pkg := BattlePkg.new()
	pkg.set_damage_type(get_damage_type())
	pkg.set_final_damages([0])
	pkg.set_actor(actor)
	pkg.set_targets(targets)
	return pkg

#func apply_pkg_to_target(pkg : BattlePkg):
	#var final_damage : int = pkg.get_final_damages()[0]
	#var actor : Familiar = pkg.get_actor()
	#var target : Familiar = pkg.get_targets()[0]
	#if(target != null):
		#var target_hp = target.current_hp
		#var new_target_hp = target_hp - final_damage
		#if(new_target_hp <= 0):
			#new_target_hp = 0
			#if(!target.is_dead()):
				#kill_target(actor,target)
		#target.set_current_hp(new_target_hp)
#
#func apply_buffs_to_pkg(pkg : BattlePkg) -> BattlePkg:
	#var actor : Familiar = pkg.get_actor()
	#var target : Familiar = pkg.get_targets()[0]
	#for buff : BattleBuff in actor.get_battle_buffs():
		#if(buff != null):
			#pkg = buff.apply_to_pkg(actor,pkg)
	#if(target != null):
		#for buff : BattleBuff in target.get_battle_buffs(): 
			#if(buff != null):
				#pkg = buff.apply_to_pkg(target,pkg)
	#return pkg

func exit_action():
	clean_up()
	battle_sys_ref.start_wait_timer(0.5)
	battle_sys_ref.get_next_action()

func action_process(actor : Familiar, targets : Array[Familiar]):
	battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
	if(!announced_push):
		if(targets.size() > 0 and targets[0] != null):
			var announcement : String = get_announcement(actor,targets[0])
			battle_sys_ref.play_messages([announcement])
			announced_push = true
		else:
			exit_action()
	if(!made_push):
		if(targets.size() > 0):
			if(targets[0] != null):
				battle_sys_ref.start_wait_timer(0.5)
				var target : Familiar = targets[0]
				var pkg : BattlePkg = get_battle_pkg(actor, targets)
				battle_sys_ref.shift_familiar(target,direction)
				visual_effects(pkg)
				made_push = true
			else:
				exit_action()
		else:
			exit_action()
	else:
		exit_action()
