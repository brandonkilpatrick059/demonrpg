extends BattleBuff

var damage_reduction : int = 0

func set_damage_reduction(reduction : int):
	damage_reduction = reduction
	$Label.text = str(reduction)

func _ready():
	modulate = Color(1,1,1,0)
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	fade_node.set_target_modulate(Color(1,1,1,1),0.2,0.2)
	add_child(fade_node)

func set_lifetime(rounds : int):
	inactive_after_rounds = rounds

func get_type():
	return "evil_eye"

func stack(stack_buff : BattleBuff):
	return

func apply_to_pkg(buff_holder : Familiar, pkg : BattlePkg) -> BattlePkg:
	if(buff_holder in pkg.targets):
		var new_final_damage = pkg.get_final_damage()
		new_final_damage = new_final_damage * 2
		pkg.set_final_damage(new_final_damage)
		var battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
		battle_sys_ref.play_sound(load("res://audio/effects/evil_eye.ogg"))
		active = false
	return pkg

func _physics_process(delta: float) -> void:
	if(not active):
		queue_free()
	else:
		check_round_lifetime()
