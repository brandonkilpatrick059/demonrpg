class_name FamiliarSummary extends Node2D

var familiars : Array[Familiar]
var familiar_index : int = 0
var current_familiar : Familiar

@onready var action_tabs : Array[SummaryActionTab] = [
	$summary_action_tab,
	$summary_action_tab2,
	$summary_action_tab3,
	$summary_action_tab4,
	$summary_action_tab5,
	$summary_action_tab6,
	$summary_action_tab7,
	$summary_action_tab8,
]

func _ready():
	$AudioStreamPlayer.stream = load("res://audio/effects/bell_quick.ogg")
	$AudioStreamPlayer.play()

func set_familiars(new_familiars : Array[Familiar]):
	familiars = new_familiars
	set_familiar(familiars[0])
	familiar_index = 0
	if familiars.size() > 1:
		show_arrows()
	else:
		hide_arrows()

func set_familiar(familiar : Familiar):
	if(current_familiar != null):
		current_familiar.set_inactive()
		var player = get_tree().get_first_node_in_group("player")
		current_familiar.reparent(player)
	current_familiar = familiar
	current_familiar.reparent($familiar_slot)
	familiar.set_active()
	familiar.position = Vector2(0,0)
	$name_label.parse_bbcode(familiar.get_familiar_name())
	var hp_gauge : HPGauge = $hp_gauge
	var hp_fraction : float = float(familiar.get_current_hp())/float(familiar.get_max_hp())
	var no_animate : bool = true
	hp_gauge.set_gauge(hp_fraction, no_animate)
	$hp.text = str(str(familiar.get_current_hp(),"/"),familiar.get_max_hp())
	$power.text = str("POWER : ",familiar.get_exp())
	$to_next.text = str("NEXT : ",familiar.get_exp_to_next())
	$attack.text = str("ATTACK : ",familiar.get_attack())
	$defense.text = str("DEFENSE : ",familiar.get_defense())
	$speed.text = str("SPEED : ",familiar.get_speed())
	$magic.text = str("MAGIC : ",familiar.get_magic())
	$actions.text = str("ACTIONS : ",familiar.get_num_actions())
	set_action_tabs(familiar, familiar.get_actions())

func set_action_tabs(actor : Familiar, actions : Array[BattleAction]):
	var index = 0
	for tab : SummaryActionTab in action_tabs:
		if(index < actions.size()):
			tab.set_tab(actor,actions[index])
			index = index + 1
		else:
			tab.set_inactive()

func show_arrows():
	$arrow_left.visible = true
	$arrow_right.visible = true

func hide_arrows():
	$arrow_left.visible = false
	$arrow_right.visible = false

func handle_input():
	if(Input.is_action_just_pressed("right")):
		familiar_index = familiar_index + 1
		if(familiar_index >= familiars.size()):
			familiar_index = 0
		set_familiar(familiars[familiar_index])
		$AudioStreamPlayer.stream = load("res://audio/effects/click.ogg")
		$AudioStreamPlayer.play()
	elif(Input.is_action_just_pressed("left")):
		familiar_index = familiar_index - 1
		if(familiar_index < 0):
			familiar_index = familiars.size() - 1
		set_familiar(familiars[familiar_index])
		$AudioStreamPlayer.stream = load("res://audio/effects/click.ogg")
		$AudioStreamPlayer.play()
	if(Input.is_action_just_pressed("select") || 
	Input.is_action_just_pressed("action_1") ||
	Input.is_action_just_pressed("action_2")):
		if(current_familiar != null):
			current_familiar.set_inactive()
		var player = get_tree().get_first_node_in_group("player")
		current_familiar.reparent(player)
		get_tree().paused = false
		queue_free()

func _physics_process(delta: float) -> void:
	handle_input()
