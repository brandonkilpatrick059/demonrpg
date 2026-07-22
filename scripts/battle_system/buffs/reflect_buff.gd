extends BattleBuff

var announcement_english : String = "...But [TEAM][BUFF_HOLDER] reflects it."
var friendly_english : String = "your "
var hostile_english : String = "hostile "

func _ready():
	modulate = Color(1,1,1,0)
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	fade_node.set_target_modulate(Color(1,1,1,1),0.2,0.2)
	add_child(fade_node)
	var battle_sys_ref : BattleSystemManager = get_tree().get_first_node_in_group("battle_system")
	battle_sys_ref.play_sound(load("res://audio/effects/bell_last.ogg"))
	inactive_after_rounds = 2

func get_announcement_english(buff_holder : Familiar) -> String:
	var name = buff_holder.get_familiar_name()
	var announcement = announcement_english.replace("[BUFF_HOLDER]",name)
	var team = ""
	if(buff_holder.is_hostile()):
		team = hostile_english
	else:
		team = friendly_english
	announcement = announcement.replace("[TEAM]",team)
	return announcement

func get_type():
	return "reflect"

func stack(stack_buff : BattleBuff):
	pass

func apply_to_pkg(buff_holder : Familiar, pkg : BattlePkg) -> BattlePkg:
	if(buff_holder in pkg.targets && 
	pkg.get_damage_type() == BattleAction.DamageType.PHYSICAL):
		var new_targets : Array[Familiar] = []
		new_targets.append_array(pkg.get_targets())
		var buff_holder_index = new_targets.find(buff_holder)
		var actor : Familiar = pkg.get_actor()
		new_targets.set(buff_holder_index,actor)
		pkg.set_targets(new_targets)
		var battle_sys_ref : BattleSystemManager 
		battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
		battle_sys_ref.play_messages([get_announcement_english(buff_holder)])
		battle_sys_ref.start_awaiting_input()
		active = false
	return pkg

func _physics_process(delta: float) -> void:
	if(not active):
		queue_free()
	else:
		check_round_lifetime()
