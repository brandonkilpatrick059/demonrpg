class_name ActionMenuTab extends Node2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var label : RichTextLabel = $RichTextLabel

var action : BattleAction = null
var text : String = ""

func set_inactive():
	visible = false
	sprite.play("inactive")

func set_selected():
	sprite.play("selected")

func set_active():
	visible = true
	sprite.play("active")

func set_tab(input_action : BattleAction):
	action = input_action
	text = action.get_action_name()
	label.parse_bbcode(text)

func get_action() -> BattleAction:
	return action
