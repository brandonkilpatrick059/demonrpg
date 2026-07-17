extends BattleAction

func get_type() -> TargetType:
	return TargetType.ANY_OPPONENT

func get_action_name() -> String:
	return "ATTACK"

func run_action(actor : Familiar, targets : Array[Familiar]):
	pass
