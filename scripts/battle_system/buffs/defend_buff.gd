extends BattleBuff

var damage_reduction : int = 0

func set_damage_reduction(reduction : int):
	damage_reduction = reduction

func apply_to_pkg(pkg : BattlePkg) -> BattlePkg:
	return pkg
