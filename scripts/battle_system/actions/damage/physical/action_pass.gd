extends BattleAction

var battle_sys_ref : BattleSystemManager

func _ready() -> void:
	action_name = "PASS"
	target_type = TargetType.NO_TARGET

func exit_action():
	clean_up()
	battle_sys_ref.get_next_action()

func action_process(actor : Familiar, targets : Array[Familiar]):
	battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
	exit_action()
