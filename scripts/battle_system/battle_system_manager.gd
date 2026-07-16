class_name BattleSystemManager extends Node

@onready var action_menu : BattleActionMenu = $BattleActionMenu
@onready var message : BattleMessage = $BattleMessage
@onready var status : BattleStatus = $BattleStatus
@onready var hp_gauge : HPGauge = $hp_gauge

@export var opponent_familiars : Array[Familiar] = []
@export var player_familiars : Array[Familiar] = []

@onready var opponent_positions : Array[Node] = [
	$"familiars/opponent/1",
	$"familiars/opponent/2",
	$"familiars/opponent/3",
	$"familiars/opponent/4"
]

@onready var player_positions : Array[Node] = [
	$"familiars/player/1",
	$"familiars/player/2",
	$"familiars/player/3",
	$"familiars/player/4"
]

var battle_timer := Timer.new()

var music_player := AudioStreamPlayer.new()

var audio_players : Array[AudioStreamPlayer] = []

enum BattlePhase {START,INPUT,BATTLE,END}
var current_phase : BattlePhase = BattlePhase.START

var awaiting_input : bool = false

var battle_started : bool = false
var familiars_initialized : bool = false

var text := BattleText.new()

func _ready() -> void:
	battle_timer.one_shot = true
	add_child(battle_timer)
	hide_all_interface()
	set_up_audio()

func set_familiars(set_player_familiars : Array[Familiar], 
set_opponent_familiars : Array[Familiar]):
	player_familiars = set_player_familiars
	opponent_familiars = set_opponent_familiars
	intiialize_familiars()

func fade_in():
	var fade_node : FadeNode = load("res://utility/fade_node.tscn").instantiate()
	var fade_out = Color(1,1,1,0)
	fade_node.set_target_modulate(fade_out,0.2,0.2)
	$fade_to_black.add_child(fade_node)

func set_up_audio():
	#TODO: handle buses, dynamic music loading, etc
	add_child(music_player)
	music_player.stream = load("res://audio/music/battle_1.ogg")
	music_player.play()
	
	var index : int = 0
	var num_sound_players = 8
	while(index < num_sound_players):
		var new_sound_player := AudioStreamPlayer.new()
		add_child(new_sound_player)
		audio_players.append(new_sound_player)
		index = index + 1

func play_sound(sound : AudioStream):
	for audio_player in audio_players:
		if (not audio_player.playing):
			audio_player.stream = sound
			audio_player.play()

func hide_all_interface():
	action_menu.visible = false
	message.visible = false
	status.visible = false
	hp_gauge.visible = false

func end_awaiting_input():
	awaiting_input = false

func process_battle():
	match(current_phase):
		BattlePhase.START:
			start_process()

func intiialize_familiars():
	var open_positions : Array[int] = []
	var index = 0
	while(index < opponent_positions.size()):
		open_positions.append(index)
		index = index + 1
	for familiar in opponent_familiars:
		var pos = open_positions[randi_range(0,open_positions.size()-1)]
		open_positions.erase(pos)
		familiar.reparent(opponent_positions[pos])
		familiar.position= Vector2(0,0)
		familiar.modulate.a = 0.5
	
	index = 0
	for familiar in player_familiars:
		familiar.reparent(player_positions[index])
		familiar.position= Vector2(0,0)
		index = index + 1
	
	familiars_initialized = true

func start_process():
	if(not battle_started):
		battle_started = true
		var intro_text : String = ""
		if(opponent_familiars.size() == 1):
			intro_text = text.get_text("intro_single")
		elif(opponent_familiars.size() > 1):
			intro_text = text.get_text("intro_mult")
		message.queue_text([intro_text])
		awaiting_input = true
	if(not awaiting_input):
		current_phase = BattlePhase.INPUT
		fade_in()

func _physics_process(delta: float) -> void:
	if(not familiars_initialized):
		intiialize_familiars()
	process_battle()
