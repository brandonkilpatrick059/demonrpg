extends BattleBuff

var target : Familiar = null

func set_target(familiar : Familiar):
	target = familiar

func _ready():
	modulate = Color(1,1,1,0)
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	fade_node.set_target_modulate(Color(1,1,1,1),0.2,0.2)
	add_child(fade_node)
	
func check_round_lifetime():
	if(rounds_active >= inactive_after_rounds):
		target.hide_mini_status()
		queue_free()
		
func set_lifetime(rounds : int):
	inactive_after_rounds = rounds

func get_type():
	return "scry_eye"

func stack(stack_buff : BattleBuff):
	return

func apply_to_pkg(buff_holder : Familiar, pkg : BattlePkg) -> BattlePkg:
	return pkg

func _physics_process(delta: float) -> void:
	if(not active):
		target.hide_mini_status()
		queue_free()
	else:
		target.activate_mini_status()
		check_round_lifetime()
