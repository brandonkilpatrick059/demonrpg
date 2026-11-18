class_name PostHealBuff extends TypeItemBuff

#add this percentage on top of heal
#POSITIVE = healing is INCREASED
#NEGATIVE = healing is DECREASED
@export var heal_scale_add : float = 0.0

func get_heal_scale_add() -> float:
	return heal_scale_add
