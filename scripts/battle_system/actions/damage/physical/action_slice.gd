extends BattleAction

var announced_attack : bool = false
var made_attack : bool = false

var battle_sys_ref : BattleSystemManager

var announcment_english : String = "[TEAM][ACTOR] slices the enemy."

func get_summary(actor : Familiar)-> String:
	var summary : String = ""
	summary = str(summary,str(summary,get_action_name()))
	summary = str(summary,"-[color=white]DEALS ")
	summary = str(summary,get_min_max_string(actor.get_attack(),actor.get_attack()+actor.get_attack()))
	summary = str(summary,str("[color=darkred] PHYSICAL DAMAGE [/color]"))
	summary = str(summary,str("[color=white]TO 2 [/color]"))
	return summary

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
	if(not target.is_in_group("player_familiar")):
		ret_string = ret_string.replace("[TEAM2]",team2)
	else:
		ret_string = ret_string.replace("[TEAM2]","")
	return ret_string

func get_slain_message(actor : Familiar, target : Familiar) -> String:
	var ret_string = slain_english.replace("[TARGET]",target.get_familiar_name())
	var team : String = ""
	if (target.is_hostile()):
		team = hostile_english
	else:
		team = friendly_english
	ret_string = ret_string.replace("[TEAM]",team)
	return ret_string

func _ready() -> void:
	action_name = "SLICE"
	target_type = TargetType.TWO_ADJACENT_OPPONENT
	energy_cost = 2
	damage_type = DamageType.PHYSICAL

func clean_up():
	announced_attack = false
	made_attack = false

func visual_effects(pkg : BattlePkg):
	var final_damage : int = pkg.get_final_damages()[0]
	var actor : Familiar = pkg.get_actor()
	var target1 : Familiar = pkg.get_targets()[0]
	if(target1 != null):
		actor.play_one_shot_animation("attack")
		var glow_red_node = load("res://utility/faders/attack_glow_red.tscn").instantiate()
		target1.add_child(glow_red_node)
		if(actor.is_hostile()):
			var emerge_node = load("res://utility/faders/fade_in_and_back.tscn").instantiate()
			actor.add_child(emerge_node)
		var hp_particle = load("res://battle/effects/hp_particle.tscn").instantiate()
		battle_sys_ref.add_child(hp_particle)
		var attack_effect = load("res://battle/effects/stab_effect.tscn").instantiate()
		battle_sys_ref.add_child(attack_effect)
		hp_particle.global_position = target1.global_position
		attack_effect.global_position = target1.global_position
		hp_particle.set_particle(str(final_damage),Color(1.0, 0.26, 0.201, 1.0))
	if(pkg.get_targets().size() > 1):
		var final_damage2 : int = pkg.get_final_damages()[1]
		var target2 : Familiar = pkg.get_targets()[1]
		if(target2 != null):
			var glow_red_node2 = load("res://utility/faders/attack_glow_red.tscn").instantiate()
			target2.add_child(glow_red_node2)
			var hp_particle2 = load("res://battle/effects/hp_particle.tscn").instantiate()
			battle_sys_ref.add_child(hp_particle2)
			var attack_effect2 = load("res://battle/effects/stab_effect.tscn").instantiate()
			battle_sys_ref.add_child(attack_effect2)
			hp_particle2.global_position = target2.global_position
			attack_effect2.global_position = target2.global_position
			hp_particle2.set_particle(str(final_damage2),Color(1.0, 0.26, 0.201, 1.0))
	battle_sys_ref.play_sound(load("res://audio/effects/hit_2.ogg"))

func get_battle_pkg(actor : Familiar, targets: Array[Familiar]) -> BattlePkg:
	var index : int = 0
	var new_damages : Array[int] = []
	while(index < targets.size()):
		var target : Familiar = targets[index]
		var full_damage : int = actor.get_attack()
		var damage : int = full_damage + randi_range(0,actor.get_attack())
		var final_damage = damage
		if(final_damage <= 0):
			final_damage = 1
		new_damages.append(final_damage)
		index = index + 1
	var pkg := BattlePkg.new()
	pkg.set_damage_type(get_damage_type())
	pkg.set_final_damages(new_damages)
	pkg.set_actor(actor)
	pkg.set_targets(targets)
	return pkg

func apply_pkg_to_target(pkg : BattlePkg):
	var final_damage : int = pkg.get_final_damages()[0]
	var actor : Familiar = pkg.get_actor()
	var target1 : Familiar = pkg.get_targets()[0]
	if(target1 != null):
		var target1_hp = target1.current_hp
		var new_target1_hp = target1_hp - final_damage
		if(new_target1_hp <= 0):
			new_target1_hp = 0
			if(!target1.is_dead()):
				kill_target(actor,target1)
		target1.set_current_hp(new_target1_hp)
	if(pkg.get_targets().size() > 1):
		var final_damage2 : int = pkg.get_final_damages()[1]
		var target2 : Familiar = pkg.get_targets()[1]
		if(target2 != null):
			var target2_hp = target2.current_hp
			var new_target2_hp = target2_hp - final_damage2
			if(new_target2_hp <= 0):
				new_target2_hp = 0
				if(!target2.is_dead()):
					kill_target(actor,target2)
			target2.set_current_hp(new_target2_hp)

func apply_buffs_to_pkg(pkg : BattlePkg) -> BattlePkg:
	var actor : Familiar = pkg.get_actor()
	for buff : BattleBuff in actor.get_battle_buffs():
		if(buff != null):
			pkg = buff.apply_to_pkg(actor,pkg)
	for target in pkg.get_targets():
		if(target != null):
			for buff : BattleBuff in target.get_battle_buffs(): 
				if(buff != null):
					pkg = buff.apply_to_pkg(target,pkg)
	return pkg

func exit_action():
	battle_sys_ref.start_wait_timer(0.5)
	battle_sys_ref.get_next_action()
	clean_up()

func action_process(actor : Familiar, targets : Array[Familiar]):
	battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
	if(!announced_attack):
		if(targets[0] != null):
			var announcement : String = get_announcement(actor,targets[0])
			battle_sys_ref.play_messages([announcement])
			announced_attack = true
		else:
			exit_action()
	if(!made_attack):
		battle_sys_ref.start_wait_timer(0.5)
		var target : Familiar = targets[0]
		var pkg : BattlePkg = get_battle_pkg(actor, targets)
		pkg = apply_buffs_to_pkg(pkg)
		apply_pkg_to_target(pkg)
		visual_effects(pkg)
		#pay_energy_cost(actor)
		made_attack = true
	else:
		exit_action()
