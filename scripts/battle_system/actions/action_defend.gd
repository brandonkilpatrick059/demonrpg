extends BattleAction

func _ready() -> void:
	action_name = "DEFEND"
	target_type = TargetType.ANY_ALLY

func run_action(actor : Familiar, targets : Array[Familiar]):
	pass
