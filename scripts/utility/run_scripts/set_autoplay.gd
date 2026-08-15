extends Node

@export var audio_player : AudioStreamPlayer
@export var playing : bool = true

func run_script():
	if(playing):
		audio_player.playing = true
	else:
		audio_player.playing = false
