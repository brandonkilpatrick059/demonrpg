extends BattleAction

func get_type() -> TargetType:
	return TargetType.ANY_DEAD

func get_action_name() -> String:
	return "[color=red]FEED[/color]"

func run_action(actor : Familiar, targets : Array[Familiar]):
	pass
