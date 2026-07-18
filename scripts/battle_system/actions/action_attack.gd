extends BattleAction

var announced_attack : bool = false
var made_attack : bool = false

var battle_sys_ref : BattleSystemManager

var friendly_english : String = "your "
var hostile_english : String = "hostile "
var announcment_english : String = "[TEAM][ACTOR] attacks [TEAM2][TARGET]"
var slain_english : String = "[TEAM][TARGET] is slain"

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
	action_name = "ATTACK"
	target_type = TargetType.ANY_OPPONENT

func clean_up():
	announced_attack = false
	made_attack = false

func action_process(actor : Familiar, targets : Array[Familiar]):
	battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
	if(!announced_attack):
		var announcement : String = get_announcement(actor,targets[0])
		battle_sys_ref.play_messages([announcement])
		announced_attack = true
	if(!made_attack):
		battle_sys_ref.start_wait_timer(2.0)
		var target : Familiar = targets[0]
		var half_damage : int = actor.get_attack()/2 + 1
		var damage : int = half_damage + randi_range(0,half_damage)
		var reduction_half : int = target.get_defense()/2
		var defense_reduction : int = reduction_half + randi_range(0,reduction_half)
		var final_damage = damage - defense_reduction
		if(final_damage < 0):
			final_damage = 0
		var target_hp = target.current_hp
		var new_target_hp = target_hp - final_damage
		if(new_target_hp < 0):
			new_target_hp = 0
			target.kill()
			var slain_message : String = get_slain_message(actor, target)
			battle_sys_ref.play_messages([slain_message])
		target.set_current_hp(new_target_hp)
		var glow_red_node = load("res://utility/attack_glow_red.tscn").instantiate()
		target.add_child(glow_red_node)
		if(actor.is_hostile()):
			var emerge_node = load("res://utility/fade_in_and_back.tscn").instantiate()
			actor.add_child(emerge_node)
		var hp_particle = load("res://battle/effects/hp_particle.tscn").instantiate()
		battle_sys_ref.add_child(hp_particle)
		var attack_effect = load("res://battle/effects/attack_effect.tscn").instantiate()
		battle_sys_ref.add_child(attack_effect)
		hp_particle.global_position = target.global_position
		attack_effect.global_position = target.global_position
		hp_particle.set_particle(str(final_damage),Color(1.0, 0.26, 0.201, 1.0))
		battle_sys_ref.play_sound(load("res://audio/effects/hit_1.ogg"))
		made_attack = true
	else:
		battle_sys_ref.start_wait_timer(0.5)
		battle_sys_ref.get_next_action()
		clean_up()
