extends BattleAction

func _ready() -> void:
	action_name = "ATTACK"
	target_type = TargetType.ANY_OPPONENT

func run_action(actor : Familiar, targets : Array[Familiar]):
	pass
