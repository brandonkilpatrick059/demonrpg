extends BattleAction

var announced_attack : bool = false
var made_attack : bool = false

var battle_sys_ref : BattleSystemManager

var announcment_english : String = "[TEAM2][TARGET] bleeds"

@export var scale_damage : bool = false
@export var damage_scale: int = 0.0
@export var set_damage : int = 0

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
	action_name = "BLEED"
	target_type = TargetType.ANY_OPPONENT
	damage_type = DamageType.PHYSICAL
	energy_cost = 0

func clean_up():
	announced_attack = false
	made_attack = false

func visual_effects(pkg : BattlePkg):
	var final_damage : int = pkg.get_final_damages()[0]
	var actor : Familiar = pkg.get_actor()
	var target : Familiar = pkg.get_targets()[0]
	if(target != null):
		var glow_red_node = load("res://utility/faders/attack_glow_red.tscn").instantiate()
		target.add_child(glow_red_node)
		var hp_particle = load("res://battle/effects/hp_particle.tscn").instantiate()
		battle_sys_ref.add_child(hp_particle)
		var attack_effect = load("res://battle/effects/wither_main_effect.tscn").instantiate()
		battle_sys_ref.add_child(attack_effect)
		hp_particle.global_position = target.global_position
		attack_effect.global_position = target.global_position
		hp_particle.set_particle(str(final_damage),Color(1.0, 0.26, 0.201, 1.0))
		battle_sys_ref.play_sound(load("res://audio/effects/bleed.ogg"))

func get_battle_pkg(actor : Familiar, targets: Array[Familiar]) -> BattlePkg:
	var target : Familiar = targets[0]
	var final_damage = 0
	if(damage_scale):
		final_damage = actor.get_attack() * damage_scale
	else:
		final_damage = set_damage
	if(final_damage <= 0):
		final_damage = 1
	var pkg := BattlePkg.new()
	pkg.set_damage_type(get_damage_type())
	pkg.set_final_damages([final_damage])
	pkg.set_actor(actor)
	pkg.set_targets(targets)
	return pkg

func apply_pkg_to_target(pkg : BattlePkg):
	var final_damage : int = pkg.get_final_damages()[0]
	var actor : Familiar = pkg.get_actor()
	var target : Familiar = pkg.get_targets()[0]
	if(target != null):
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
	if(target != null && actor != null):
		for buff : BattleBuff in actor.get_battle_buffs():
			if(buff != null):
				pkg = buff.apply_to_pkg(actor,pkg)
		for buff : BattleBuff in target.get_battle_buffs(): 
			if(buff != null):
				pkg = buff.apply_to_pkg(target,pkg)
	return pkg

func action_process(actor : Familiar, targets : Array[Familiar]):
	battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
	if(!announced_attack):
		if(targets.size() > 0):
			if(targets[0] != null):
				if(targets[0].has_battle_buff("bleed")):
					var announcement : String = get_announcement(actor,targets[0])
					battle_sys_ref.play_messages([announcement])
					announced_attack = true
				else:
					exit_action()
			else:
				exit_action()
		else:
			exit_action()
	if(!made_attack):
		battle_sys_ref.start_wait_timer(0.5)
		if(targets.size() > 0):
			if(targets[0] != null):
				var target : Familiar = targets[0]
				var pkg : BattlePkg = get_battle_pkg(actor, targets)
				pkg = apply_buffs_to_pkg(pkg)
				pkg = actor.actor_apply_type_item_buffs(pkg)
				pkg = target.target_apply_type_item_buffs(pkg)
				apply_pkg_to_target(pkg)
				visual_effects(pkg)
				made_attack = true
			else:
				exit_action()
		else:
			exit_action()
	else:
		var full_action_exectued : bool = true
		exit_action(full_action_exectued)

func exit_action(full_action_executed : bool = false):
	if full_action_executed:
		battle_sys_ref.start_wait_timer(0.5)
	battle_sys_ref.get_next_action()
	clean_up()
