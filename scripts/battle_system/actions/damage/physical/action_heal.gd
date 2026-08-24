extends BattleAction

var announced_heal : bool = false
var made_heal : bool = false

var battle_sys_ref : BattleSystemManager

var announcment_english : String = "[TEAM][ACTOR] heals [TEAM][TARGET]"

func get_announcement(actor : Familiar, target : Familiar) -> String:
	var ret_string = announcment_english.replace("[ACTOR]",actor.get_familiar_name())
	ret_string = ret_string.replace("[TARGET]",target.get_familiar_name())
	var team : String = ""
	if (actor.is_hostile()):
		team = hostile_english
	else:
		team = friendly_english
	ret_string = ret_string.replace("[TEAM]",team)
	return ret_string

func _ready() -> void:
	action_name = "HEAL"
	target_type = TargetType.ANY_ALLY
	damage_type = DamageType.NONE
	target_preference = true

func get_summary(actor : Familiar)-> String:
	var summary : String = ""
	summary = str(summary,str(summary,get_action_name()))
	summary = str(summary,"-[color=lightblue]HEALS [/color][color=white]")
	summary = str(summary,get_min_max_string(get_base_heal(actor),get_base_heal(actor)+get_base_heal(actor)))
	summary = str(summary,str("[color=darkred] DAMAGE [/color]"))
	return summary

func get_base_heal(actor : Familiar) -> int:
	return actor.get_magic()/2 + 1

func clean_up():
	announced_heal = false
	made_heal = false

func visual_effects(pkg : BattlePkg):
	var final_damage : int = pkg.get_final_damages()[0]
	var actor : Familiar = pkg.get_actor()
	var target : Familiar = pkg.get_targets()[0]
	if(target != null):
		actor.play_one_shot_animation("magic")
		var glow_blue_node = load("res://utility/faders/heal_glow_blue.tscn").instantiate()
		target.add_child(glow_blue_node)
		if(actor.is_hostile()):
			var emerge_node = load("res://utility/faders/fade_in_and_back.tscn").instantiate()
			actor.add_child(emerge_node)
		var hp_particle = load("res://battle/effects/hp_particle.tscn").instantiate()
		battle_sys_ref.add_child(hp_particle)
		hp_particle.global_position = target.global_position
		hp_particle.set_particle(str(final_damage),Color(0.542, 0.691, 1.0, 1.0))
		battle_sys_ref.play_sound(load("res://audio/effects/heal.ogg"))

func get_battle_pkg(actor : Familiar, targets: Array[Familiar]) -> BattlePkg:
	var target : Familiar = targets[0]
	var base_heal : int = get_base_heal(actor)
	var heal : int = base_heal + randi_range(0,base_heal)
	var final_damage = heal
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
		var new_target_hp = target_hp + final_damage
		if(new_target_hp >= target.get_max_hp()):
			new_target_hp = target.get_max_hp()
		target.set_current_hp(new_target_hp)

func get_target_preference(targets : Array[Familiar]) -> Array[Familiar]:
	var lowest_hp : int = targets[0].get_current_hp()
	var chosen_target = targets[randi_range(0,targets.size()-1)]
	for target in targets:
		if(target.get_current_hp() < chosen_target.get_current_hp()):
			chosen_target = target
	return [chosen_target]

func apply_buffs_to_pkg(pkg : BattlePkg) -> BattlePkg:
	var actor : Familiar = pkg.get_actor()
	var target : Familiar = pkg.get_targets()[0]
	for buff : BattleBuff in actor.get_battle_buffs():
		if(buff != null):
			pkg = buff.apply_to_pkg(actor,pkg)
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
	if(!announced_heal):
		if(targets[0] != null):
			var announcement : String = get_announcement(actor,targets[0])
			battle_sys_ref.play_messages([announcement])
			announced_heal = true
		else:
			exit_action()
	if(!made_heal):
		battle_sys_ref.start_wait_timer(0.5)
		var pkg : BattlePkg = get_battle_pkg(actor, targets)
		#pkg = apply_buffs_to_pkg(pkg)
		apply_pkg_to_target(pkg)
		visual_effects(pkg)
		made_heal = true
	else:
		exit_action()
