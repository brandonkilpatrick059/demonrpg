class_name MiniBattleStatus extends Node2D

@onready var hp_gauge : HPGauge = $hp_gauge
@onready var energy_gauge : AnimatedSprite2D = $energy_gauge

var active : bool = false

func is_active() -> bool:
	return active

func set_active():
	visible = true
	active = true

func set_inactive():
	visible = false
	active = false

func set_energy_gauge(num : int):
	energy_gauge.frame = num

func set_hp_gauge(fraction : float, no_animate : bool = false):
	hp_gauge.set_gauge(fraction,no_animate)
