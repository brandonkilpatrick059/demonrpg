class_name AudioPlayer extends Node

var audio_player := AudioStreamPlayer.new()
var audio_player1 := AudioStreamPlayer.new() 
var audio_player2 := AudioStreamPlayer.new() 
var audio_player3 := AudioStreamPlayer.new() 
var audio_player4 := AudioStreamPlayer.new()
var audio_player5 := AudioStreamPlayer.new()
var audio_player6 := AudioStreamPlayer.new() 
var audio_player7 := AudioStreamPlayer.new() 
var audio_player8 := AudioStreamPlayer.new() 
var audio_player9 := AudioStreamPlayer.new()
var audio_players : Array[AudioStreamPlayer] = []

func _ready() -> void:	
	audio_players = [audio_player,audio_player1,audio_player2,audio_player3,audio_player4,
	audio_player5,audio_player6,audio_player7,audio_player8,audio_player9]
	for player : AudioStreamPlayer in audio_players:
		player.bus = "effects"
		add_child(player)

func play_audio(stream : AudioStream):
	for player : AudioStreamPlayer in audio_players:
		if not player.playing:
			player.stream = stream
			player.play()
			return
