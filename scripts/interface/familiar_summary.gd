class_name FamiliarSummary extends Node2D

var familiars : Array[Familiar]
var familiar_index : int = 0
var current_familiar : Familiar

var showing_item : bool = false

var selection_callback_node : Node = null
var select_mode : bool = false

var equip_item_mode : bool = false
var item_to_equip : EquipItem = null

@onready var action_tabs : Array[SummaryActionTab] = [
	$summary_action_tabs/summary_action_tab,
	$summary_action_tabs/summary_action_tab2,
	$summary_action_tabs/summary_action_tab3,
	$summary_action_tabs/summary_action_tab4,
	$summary_action_tabs/summary_action_tab5,
	$summary_action_tabs/summary_action_tab6,
	$summary_action_tabs/summary_action_tab7,
	$summary_action_tabs/summary_action_tab8,
]

var equip_exit_timer := Timer.new()
var equip_exiting : bool = false

func _ready():
	$AudioStreamPlayer.stream = load("res://audio/effects/bell_quick.ogg")
	$AudioStreamPlayer.play()
	equip_exit_timer.one_shot = true
	add_child(equip_exit_timer)

func set_select_mode(callback_node : Node):
	selection_callback_node = callback_node
	disable_equip_item_mode()
	select_mode = true

func set_equip_item_mode(equip_item : EquipItem, callback_node : Node):
	set_select_mode(callback_node)
	$summary_action_tabs.visible = false
	$EquipItemSummary.set_equip_item(equip_item)
	$EquipItemSummary.visible = true
	item_to_equip = equip_item
	equip_item_mode = true

func disable_equip_item_mode():
	$summary_action_tabs.visible = true
	$EquipItemSummary.set_equip_item(null)
	$EquipItemSummary.visible = false
	item_to_equip = null
	equip_item_mode = false

func set_familiars(new_familiars : Array[Familiar]):
	if(new_familiars.size() > 0):
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
	if(familiar.is_in_group("player_familiar")):
		$power.visible = false
		$to_next.visible = false
		$seal_counter.visible = true
		$type_interface.visible = false
		var player_ref : Player = get_tree().get_first_node_in_group("player")
		$seal_counter/seal_label.text = str("x",player_ref.get_pentacle_charms())
		$equip_item_interface.visible = false
	else:
		$power.visible = true
		$to_next.visible = true
		$seal_counter.visible = false
		$type_interface.visible = true
		$equip_item_interface.visible = true
	current_familiar = familiar
	current_familiar.reparent($familiar_slot)
	familiar.set_active()
	if(familiar.is_dead()):
		familiar.play_animation("dead")
	familiar.position = Vector2(0,0)
	$name_label.parse_bbcode(familiar.get_familiar_name())
	var hp_gauge : HPGauge = $hp_gauge
	var hp_fraction : float = float(familiar.get_current_hp())/float(familiar.get_max_hp())
	var no_animate : bool = true
	hp_gauge.set_gauge(hp_fraction, no_animate)
	if(familiar.get_exp_to_next_int() > 0):
		$power_gauge.visible = true
		var exp_fraction : float = float(familiar.get_exp())/float(familiar.get_exp_to_next_int())
		$power_gauge.set_gauge(exp_fraction, no_animate)
	else:
		$power_gauge.visible = false
	$hp.text = str(str(familiar.get_current_hp(),"/"),familiar.get_max_hp())
	$power.text = str("POWER : ",familiar.get_exp())
	$to_next.text = str("NEXT : ",familiar.get_exp_to_next())
	$attack.text = str("ATTACK : ",familiar.get_attack())
	$defense.text = str("DEFENSE : ",familiar.get_defense())
	$speed.text = str("SPEED : ",familiar.get_speed())
	$magic.text = str("MAGIC : ",familiar.get_magic())
	$actions.text = str("ACTIONS : ",familiar.get_num_actions())
	$level.text = str("LEVEL: ",familiar.get_level())
	if(familiar.is_stored()):
		$stored_label.visible = true
	else:
		$stored_label.visible = false
	var familiar_type = familiar.get_familiar_type()
	if(familiar_type != null):
		$type_interface/type_label.parse_bbcode(familiar_type.get_type_name_text())
		$type_interface/description_label_1.parse_bbcode(familiar_type.get_description_1())
		$type_interface/description_label_2.parse_bbcode(familiar_type.get_description_2())
	else:
		$type_interface.visible = false
	set_action_tabs(familiar, familiar.get_actions())
	if(familiar.get_equipped_item() != null):
		set_equip_item(familiar.get_equipped_item())
	else:
		clear_equip_item()

func set_equip_item(equip_item : EquipItem):
	var item_name : String = equip_item.get_item_name_text()
	$equip_item_interface/equip_item_label.parse_bbcode(item_name)
	var item_description : String = equip_item.get_description()
	$equip_item_interface/description_box/description_label.parse_bbcode(item_description)
	var item_sprite : SpriteFrames = equip_item.get_sprite_frames()
	$equip_item_interface/sprite.sprite_frames = item_sprite

func clear_equip_item():
	$equip_item_interface/equip_item_label.parse_bbcode("EMPTY")
	$equip_item_interface/description_box/description_label.parse_bbcode("")
	$equip_item_interface/sprite.sprite_frames = null

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

func show_item():
	showing_item = true
	$type_interface.modulate = Color(0.5,0.5,0.5)
	$equip_item_interface.modulate = Color(1,1,1)
	$equip_item_interface/description_box.visible = true
	$equip_item_interface/sprite.play("default")

func hide_item():
	showing_item = false
	$type_interface.modulate = Color(1,1,1)
	$equip_item_interface.modulate = Color(0.5,0.5,0.5)
	$equip_item_interface/description_box.visible = false
	$equip_item_interface/sprite.stop()

func handle_input():
	if(Input.is_action_just_pressed("right")):
		if(familiars[familiar_index].get_equipped_item() != null and not
		showing_item):
			show_item()
		else:
			hide_item()
			familiar_index = familiar_index + 1
			if(familiar_index >= familiars.size()):
				familiar_index = 0
			set_familiar(familiars[familiar_index])
		$AudioStreamPlayer.stream = load("res://audio/effects/click.ogg")
		$AudioStreamPlayer.play()
	elif(Input.is_action_just_pressed("left")):
		if(familiars[familiar_index].get_equipped_item() != null and
		showing_item):
			hide_item()
		else:
			familiar_index = familiar_index - 1
			if(familiar_index < 0):
				familiar_index = familiars.size() - 1
			set_familiar(familiars[familiar_index])
		$AudioStreamPlayer.stream = load("res://audio/effects/click.ogg")
		$AudioStreamPlayer.play()
	if(select_mode and 
	Input.is_action_just_pressed("action_1")):
		if(equip_item_mode):
			set_equip_item(item_to_equip)
			show_item()
			disable_equip_item_mode()
			$AudioStreamPlayer.stream = load("res://audio/effects/equip.ogg")
			$AudioStreamPlayer.play()
		else:
			clear_equip_item()
			$AudioStreamPlayer.stream = load("res://audio/effects/unequip.ogg")
			$AudioStreamPlayer.play()
		equip_exit_timer.start(1.0)
		equip_exiting = true
		select_mode = false
		#exit_summary()
	elif(select_mode and 
	(Input.is_action_just_pressed("select") || 
	Input.is_action_just_pressed("action_2"))):
		selection_callback_node.summary_exit_callback()
		select_mode = false
		exit_summary()
	elif(Input.is_action_just_pressed("select") || 
	Input.is_action_just_pressed("action_2")):
		exit_summary()

func exit_summary():
	if(current_familiar != null):
		current_familiar.set_inactive()
	var player = get_tree().get_first_node_in_group("player")
	current_familiar.reparent(player)
	get_tree().paused = false
	if(equip_item_mode):
		disable_equip_item_mode()
	queue_free()

func _physics_process(delta: float) -> void:
	if(not equip_exiting):
		handle_input()
	elif(equip_exit_timer.is_stopped()):
		selection_callback_node.summary_select_callback(familiars[familiar_index])
		exit_summary()
