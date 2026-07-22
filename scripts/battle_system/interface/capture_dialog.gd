class_name CaptureDialog extends Node2D

@onready var label : RichTextLabel = $Label
@onready var yes_label : Label = $yes_label
@onready var no_label : Label = $no_label
@onready var yes_arrow : Sprite2D = $yes_arrow
@onready var no_arrow : Sprite2D = $no_arrow
@onready var seal_label : Label = $seal_label

var label_english : String = "Use a [color=purple]PENTACLE SEAL[/color] to bring
the [color=red][NAME][/color] under your control?"
var yes_english : String = "YES"
var no_english : String = "NO"

var yes_selected : bool = false

var active : bool = false

var audio_player := AudioStreamPlayer.new()

var target_familiar : Familiar = null

var input_timer := Timer.new()

func set_target(familiar : Familiar):
	var name : String = familiar.get_familiar_name().to_upper()
	var text : String = label_english.replace("[NAME]",name)
	target_familiar = familiar
	label.parse_bbcode(text)

func _ready() -> void:
	yes_label.text = yes_english
	no_label.text = no_english
	var player : Player = get_tree().get_first_node_in_group("player")
	var num_charms = player.get_pentacle_charms()
	seal_label.text = str("x",str(num_charms))
	add_child(audio_player)
	input_timer.one_shot = true
	add_child(input_timer)

func update_selected():
	if(yes_selected):
		yes_arrow.visible = true
		no_arrow.visible = false
	else:
		no_arrow.visible = true
		yes_arrow.visible = false

func set_active():
	visible = true
	active = true
	update_selected()
	input_timer.start(1.0)

func set_inactive():
	visible = false
	active = false

func handle_input():
	if(active && input_timer.is_stopped()):
		if(Input.is_action_just_pressed("up")):
			if(not yes_selected):
				yes_selected = true
				update_selected()
				audio_player.stream = load("res://audio/effects/click.ogg")
				audio_player.play()
			else:
				audio_player.stream = load("res://audio/effects/short_bell.ogg")
				audio_player.play()
		elif(Input.is_action_just_pressed("down")):
			if(yes_selected):
				yes_selected = false
				update_selected()
				audio_player.stream = load("res://audio/effects/click.ogg")
				audio_player.play()
			else:
				audio_player.stream = load("res://audio/effects/short_bell.ogg")
				audio_player.play()
		elif(Input.is_action_just_pressed("action_1")):
			set_inactive()
			var battle_system : BattleSystemManager
			battle_system = get_tree().get_first_node_in_group("battle_system")
			if(yes_selected):
				battle_system.set_capture_accepted()
				battle_system.end_awaiting_input()
			else:
				target_familiar.set_capture_offered()
				battle_system.end_awaiting_input()
			audio_player.stream = load("res://audio/effects/bell_first.ogg")
			audio_player.play()

func _physics_process(delta: float) -> void:
	handle_input()
