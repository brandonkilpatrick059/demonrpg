class_name BattleStatus extends Node2D

@onready var hp_gauge : HPGauge = $hp_gauge
@onready var label : RichTextLabel = $name_label
@onready var energy_gauge : AnimatedSprite2D = $energy_gauge
@onready var num_acts_tab : Sprite2D = $num_acts_tab

func _ready():
	energy_gauge.visible = false
	num_acts_tab.visible = false

func set_hp_gauge(fraction : float, no_animate : bool = false):
	hp_gauge.set_gauge(fraction,no_animate)

func is_finished_animating() -> bool:
	return hp_gauge.is_finished_animating()

func set_name_label(text : String):
	label.parse_bbcode(text)
