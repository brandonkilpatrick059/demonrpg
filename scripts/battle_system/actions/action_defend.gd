extends BattleAction

func get_type() -> TargetType:
	return TargetType.ANY_ALLY

func get_action_name() -> String:
	return "DEFEND"

func run_action(actor : Familiar, targets : Array[Familiar]):
	pass
