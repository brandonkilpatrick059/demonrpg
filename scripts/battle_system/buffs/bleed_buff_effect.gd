extends BattleBuff

#var source_familiar : Familiar
#var target_familiar : Familiar

@onready var bleed_action : BattleAction = $ActionBleed

#func set_source_and_target(familiar : Familiar, target: Familiar):
	#source_familiar = familiar
	#target_familiar = target

func _ready():
	modulate = Color(1,1,1,0)
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	fade_node.set_target_modulate(Color(1,1,1,1),0.2,0.2)
	add_child(fade_node)
	status_effect = true
	cured_by_heal = true
	inactive_after_rounds = randi_range(2,4)

#func set_lifetime(rounds : int):
	#inactive_after_rounds = rounds

func get_type():
	return "bleed"

func apply_status_effect():
	var action_item : BattleSystemManager.ActionQueueItem
	var source = source_familiar
	var act = bleed_action.duplicate()
	var target = target_familiar
	if(target != null and source != null):
		var battle_system_ref : BattleSystemManager
		battle_system_ref = get_tree().get_first_node_in_group("battle_system")
		battle_system_ref.add_child(act)
		action_item = BattleSystemManager.ActionQueueItem.new(source,act,[target])
		battle_system_ref.append_special_action_queue(action_item)
	else:
		queue_free()

func stack(stack_buff : BattleBuff):
	return

func _physics_process(delta: float) -> void:
	if(not active):
		queue_free()
	else:
		check_round_lifetime()
