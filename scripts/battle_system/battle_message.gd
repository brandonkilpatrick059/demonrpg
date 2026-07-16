class_name BattleMessage extends Node2D

@onready var label : RichTextLabel = $RichTextLabel

var timer := Timer.new()
var text_speed : float = 0.08

var current_text : String = ""
var full_text : String = ""
var finished_writing : bool = false
var text_index : int = 0

var audio_player := AudioStreamPlayer.new() 

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	#TODO: figure out audio bus 
	add_child(audio_player)
	audio_player.stream = load("res://audio/effects/click.ogg")

func play_text(text : String):
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
			audio_player.play()
	else:
		finished_writing = true

func is_finished_writing() -> bool:
	return finished_writing

func _physics_process(_delta: float) -> void:
	if(not finished_writing):
		write_text()
