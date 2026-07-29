class_name SummaryActionTab extends AnimatedSprite2D

func set_tab(actor : Familiar, action : BattleAction):
	play("active")
	$RichTextLabel.parse_bbcode(action.get_summary(actor))
	$energy_cost.frame = action.get_energy_cost()

func set_inactive():
	$RichTextLabel.parse_bbcode("")
	$energy_cost.frame = 0
	play("inactive")
