class_name BattleStatus extends Node2D

@onready var hp_gauge : HPGauge = $hp_gauge
@onready var label : RichTextLabel = $name_label
@onready var energy_gauge : AnimatedSprite2D = $energy_gauge
@onready var num_acts_tab : Sprite2D = $num_acts_tab

var active : bool = false

var audio_player := AudioStreamPlayer.new()

func _ready():
	#energy_gauge.visible = false
	num_acts_tab.visible = false
	#TODO: buses
	add_child(audio_player)

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

func set_hp_gauge(fraction : float, current_hp : int, max_hp : int, no_animate : bool = false):
	hp_gauge.set_gauge(fraction,no_animate)
	var health_string = str(str(str(current_hp),"/"),max_hp)
	$hp_label.parse_bbcode(health_string)

func is_finished_animating() -> bool:
	return hp_gauge.is_finished_animating()

func set_name_label(text : String):
	label.parse_bbcode(text)

func handle_input():
	if(active):
		if(Input.is_action_just_pressed("action_1")):
			set_inactive()
			var battle_system : BattleSystemManager
			battle_system = get_tree().get_first_node_in_group("battle_system")
			battle_system.end_awaiting_input()
			audio_player.stream = load("res://audio/effects/brush_snare.ogg")
			audio_player.play()

func _physics_process(delta: float) -> void:
	handle_input()
