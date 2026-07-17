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

var familiars_initialized : bool = false

var text := BattleText.new()

class ActionQueueItem:
	var actor : Familiar = null
	var action : BattleAction = null
	var targets : Array[Familiar] = []
	
	func _init(in_actor : Familiar, 
	in_action : BattleAction, 
	in_targets : Array[Familiar]) -> void:
		actor = in_actor
		action = in_action
		targets = in_targets
	
	func get_actor() -> Familiar:
		return actor
	
	func get_action() -> BattleAction:
		return action
	
	func get_targets() -> Array[Familiar]:
		return targets

var player_action_queue : Array[ActionQueueItem] = []
var opponent_action_queue : Array[ActionQueueItem] = []
var combined_action_queue : Array[ActionQueueItem] = []

func _ready() -> void:
	battle_timer.one_shot = true
	add_child(battle_timer)
	hide_all_interface()
	set_up_audio()
	add_to_group("battle_system")

func set_familiars(set_player_familiars : Array[Familiar], 
set_opponent_familiars : Array[Familiar]):
	player_familiars = set_player_familiars
	opponent_familiars = set_opponent_familiars
	initialize_familiars()

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

func start_awaiting_input():
	awaiting_input = true

func initialize_familiars():
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

#region Process
func _physics_process(delta: float) -> void:
	if(not familiars_initialized):
		initialize_familiars()
	process_battle()

func process_battle():
	match(current_phase):
		BattlePhase.START:
			start_process()
		BattlePhase.INPUT:
			input_process()

#region Start Phase
var battle_started : bool = false
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
#endregion

#region Input Phase
#endregion
var player_familiar_index : int = 0
var status_shown : bool = false
func input_process():
	if(player_familiar_index < player_familiars.size()):
		var current_familiar = player_familiars[player_familiar_index]
		if(not familiar_in_action_queue(current_familiar)):
			if(not status_shown):
				show_status(current_familiar)
				status_shown = true
			elif(status_shown && not awaiting_input):
				show_action_menu(current_familiar)
				awaiting_input = true
		else:
			player_familiar_index = player_familiar_index + 1

func show_status(familiar : Familiar): 
	status.global_position = familiar.global_position + Vector2(0,-64)
	status.set_name_label(familiar.get_familiar_name())
	var current_hp = familiar.get_current_hp()
	var max_hp = familiar.get_max_hp()
	var hp_fraction : float = float(current_hp / max_hp)
	var dont_animate : bool = true
	status.set_hp_gauge(hp_fraction,dont_animate)
	status.set_active()
	awaiting_input = true

func show_action_menu(familiar : Familiar):
	action_menu.set_actions(familiar.get_actions())
	var height = -16 - action_menu.get_height()
	action_menu.global_position = familiar.global_position + Vector2(0,height)
	action_menu.set_active()

func reset_show_status():
	status_shown = false
	awaiting_input =false

func familiar_in_action_queue(familiar : Familiar) -> bool:
	for action_item : ActionQueueItem in player_action_queue:
		if(action_item.actor == familiar):
			return true
	return false
#endregion
