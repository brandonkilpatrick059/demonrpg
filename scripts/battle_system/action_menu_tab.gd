class_name ActionMenuTab extends Node2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var label : RichTextLabel = $RichTextLabel

var action_node : BattleAction = null
var text : String = ""

func set_inactive():
	sprite.play("inactive")

func set_selected():
	sprite.play("selected")

func set_active():
	sprite.play("active")

func set_tab(action : BattleAction):
	action_node = action
	text = action.get_action_name()
	label.parse_bbcode(text)

func get_action_node() -> BattleAction:
	return action_node
