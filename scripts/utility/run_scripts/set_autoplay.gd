extends Node

@export var audio_player : AudioStreamPlayer
@export var autoplay : bool = true

func run_script():
	if(autoplay):
		audio_player.playing = true
	else:
		audio_player.playing = false
