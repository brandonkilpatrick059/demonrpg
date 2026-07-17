class_name BattleMessage extends Node2D

@onready var label : RichTextLabel = $RichTextLabel

var timer := Timer.new()
var text_speed : float = 0.04

var current_text : String = ""
var full_text : String = ""
var finished_writing : bool = false
var text_index : int = 0

var audio_player := AudioStreamPlayer.new() 

var active : bool = false

var text_queue : Array[String] = []

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	#TODO: figure out audio bus 
	add_child(audio_player)

func is_active() -> bool:
	return active

func set_active():
	visible = true
	active = true

func set_inactive():
	visible = false
	active = false

func queue_text(texts : Array[String]):
	for text in texts:
		text_queue.append(text)
	play_next_text()

func play_next_text():
	var text = text_queue.pop_front()
	play_text(text)

func play_text(text : String):
	set_active()
	finished_writing = false
	full_text = text
	current_text = ""
	update_label()
	text_index = 0

func update_label():
	label.parse_bbcode(current_text)

func write_text():
	if(current_text != full_text):
		if(timer.is_stopped()):
			text_index = text_index + 1
			current_text = full_text.substr(0,text_index)
			timer.start(text_speed)
			update_label()
			audio_player.stream = load("res://audio/effects/click.ogg")
			audio_player.play()
	else:
		finished_writing = true

func is_finished_writing() -> bool:
	return finished_writing

func handle_input():
	if(is_active()):
		if(Input.is_action_just_pressed("action_1")):
			if(not finished_writing):
				current_text = full_text
				update_label()
				finished_writing = true
			elif(finished_writing):
				if(text_queue.size() > 0):
					play_next_text()
				else:
					set_inactive()
					var battle_system : BattleSystemManager
					battle_system = get_tree().get_first_node_in_group("battle_system")
					battle_system.end_awaiting_input()
					audio_player.stream = load("res://audio/effects/brush_snare.ogg")
				audio_player.play()

func _physics_process(_delta: float) -> void:
	if(not finished_writing):
		write_text()
	handle_input()
