extends BattleAction

var announced_attack : bool = false
var made_attack : bool = false

var battle_sys_ref : BattleSystemManager

var announcment_english : String = "[TEAM][ACTOR] burns [TEAM2][TARGET]"

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
	action_name = "FIRE"
	target_type = TargetType.ANY_OPPONENT
	damage_type = DamageType.MAGIC
	energy_cost = 2

func clean_up():
	announced_attack = false
	made_attack = false

func visual_effects(pkg : BattlePkg):
	var final_damage : int = pkg.get_final_damage()
	var actor : Familiar = pkg.get_actor()
	var target : Familiar = pkg.get_targets()[0]
	actor.play_one_shot_animation("magic")
	var glow_red_node = load("res://utility/faders/attack_glow_red.tscn").instantiate()
	target.add_child(glow_red_node)
	var hp_particle = load("res://battle/effects/hp_particle.tscn").instantiate()
	battle_sys_ref.add_child(hp_particle)
	var attack_effect = load("res://battle/effects/fire_main_effect.tscn").instantiate()
	battle_sys_ref.add_child(attack_effect)
	var attack_effect2 = load("res://battle/effects/stab_effect.tscn").instantiate()
	battle_sys_ref.add_child(attack_effect2)
	hp_particle.global_position = target.global_position
	attack_effect.global_position = target.global_position
	attack_effect2.global_position = target.global_position
	hp_particle.set_particle(str(final_damage),Color(1.0, 0.26, 0.201, 1.0))
	battle_sys_ref.play_sound(load("res://audio/effects/fire.ogg"))
	battle_sys_ref.play_sound(load("res://audio/effects/magic.ogg"))
	battle_sys_ref.play_sound(load("res://audio/effects/stab.ogg"))

func get_battle_pkg(actor : Familiar, targets: Array[Familiar]) -> BattlePkg:
	var target : Familiar = targets[0]
	var base_damage : int = actor.get_magic()
	var damage_reduction : int = target.get_magic() / 2
	var damage : int = base_damage + randi_range(0,base_damage)
	var final_damage = damage - randi_range(0,damage_reduction)
	if(final_damage <= 0):
		final_damage = 1
	var pkg := BattlePkg.new()
	pkg.set_damage_type(get_damage_type())
	pkg.set_final_damage(final_damage)
	pkg.set_actor(actor)
	pkg.set_targets(targets)
	return pkg

func apply_pkg_to_target(pkg : BattlePkg):
	var final_damage : int = pkg.get_final_damage()
	var actor : Familiar = pkg.get_actor()
	var target : Familiar = pkg.get_targets()[0]
	var target_hp = target.current_hp
	var new_target_hp = target_hp - final_damage
	if(new_target_hp <= 0):
		new_target_hp = 0
		if(!target.is_dead()):
			kill_target(actor,target)
	target.set_current_hp(new_target_hp)

func apply_buffs_to_pkg(pkg : BattlePkg) -> BattlePkg:
	var actor : Familiar = pkg.get_actor()
	var target : Familiar = pkg.get_targets()[0]
	for buff : BattleBuff in actor.get_battle_buffs():
		if(buff != null):
			pkg = buff.apply_to_pkg(actor,pkg)
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
		var burn = load("res://battle/actions/buffs/burn_buff_effect.tscn").instantiate()
		burn.set_source_and_target(actor,target)
		target.add_battle_buff(burn)
		visual_effects(pkg)
		#pay_energy_cost(actor)
		made_attack = true
	else:
		exit_action()
