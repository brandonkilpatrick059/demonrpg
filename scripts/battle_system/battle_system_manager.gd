class_name BattleSystemManager extends Node

@onready var action_menu : BattleActionMenu = $BattleActionMenu
@onready var message : BattleMessage = $BattleMessage
@onready var status : BattleStatus = $BattleStatus
@onready var hp_gauge : HPGauge = $hp_gauge

@export var opponent_familiars : Array[Familiar] = []
@export var player_familiars : Array[Familiar] = []

var text := BattleText.new()

@onready var opponent_positions : Array[FamiliarSlot] = [
	$"familiars/opponent/1",
	$"familiars/opponent/2",
	$"familiars/opponent/3",
	$"familiars/opponent/4"
]

@onready var player_positions : Array[FamiliarSlot] = [
	$"familiars/player/1",
	$"familiars/player/2",
	$"familiars/player/3",
	$"familiars/player/4"
]

var wait_timer := Timer.new()

var music_player := AudioStreamPlayer.new()
var audio_players : Array[AudioStreamPlayer] = []

#STATE INFO
enum BattlePhase {START,INPUT,INPUT_TARGET,BATTLE,END}
var current_phase : BattlePhase = BattlePhase.START
var awaiting_input : bool = false
var familiars_initialized : bool = false

class ActionQueueItem:
	var actor : Familiar = null
	var action : BattleAction = null
	var targets : Array[Familiar] = []
	
	func _init(in_actor : Familiar, 
	in_action : BattleAction, 
	in_targets : Array[Familiar]) -> void:
		actor = in_actor
		action = in_action
		targets.append_array(in_targets)
	
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
	wait_timer.one_shot = true
	add_child(wait_timer)
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
			return

func hide_all_interface():
	action_menu.visible = false
	message.visible = false
	status.visible = false
	hp_gauge.visible = false

func end_awaiting_input():
	awaiting_input = false

func start_awaiting_input():
	awaiting_input = true

func is_awaiting_input():
	return awaiting_input

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
		familiar.mark_hostile()
	
	index = 0
	for familiar in player_familiars:
		familiar.reparent(player_positions[index])
		familiar.position= Vector2(0,0)
		index = index + 1
	
	familiars_initialized = true

func play_messages(text_queue : Array[String]):
	message.queue_text(text_queue)
	awaiting_input = true

func start_wait_timer(time : float):
	wait_timer.start(time)

#region Process
func _physics_process(delta: float) -> void:
	if(not familiars_initialized):
		initialize_familiars()
	process_battle()

func process_battle():
	if(wait_timer.is_stopped()):
		match(current_phase):
			BattlePhase.START:
				start_process()
			BattlePhase.INPUT:
				input_process()
			BattlePhase.INPUT_TARGET:
				target_process()
			BattlePhase.BATTLE:
				battle_process()

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
		play_messages([intro_text])
	if(not awaiting_input):
		current_phase = BattlePhase.INPUT
		wait_timer.start(3.0)
		fade_in()
#endregion
#region Input Phase
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
	var hp_fraction : float = float(current_hp) / float(max_hp)
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
#region Input Target Phase
var targeted_familiars : Array[Familiar] = []
var targetable_familiars: Array[Familiar] = []
var targeting_action : BattleAction

func start_target_process(action : BattleAction):
	current_phase = BattlePhase.INPUT_TARGET
	targeting_action = action
	end_awaiting_input()
	get_targetable_familiars(targeting_action)

func reset_input_phase():
	hide_all_sel_arrows()
	current_phase = BattlePhase.INPUT

func get_targetable_familiars(action : BattleAction):
	targetable_familiars.clear()
	targeted_familiars.clear()
	var target_type : BattleAction.TargetType = action.get_target_type()
	match target_type:
		BattleAction.TargetType.NO_TARGET:
			pass
		BattleAction.TargetType.ANY_OPPONENT:
			for opponent in opponent_familiars:
				if(not opponent.is_dead()):
					targetable_familiars.append(opponent)
		BattleAction.TargetType.ANY_ALLY:
			for familiar in player_familiars:
				if(not familiar.is_dead()):
					targetable_familiars.append(familiar)
		BattleAction.TargetType.ANY_DEAD:
			for opponent in opponent_familiars:
				if(opponent.is_dead()):
					targetable_familiars.append(opponent)
			for familiar in player_familiars:
				if(familiar.is_dead()):
					targetable_familiars.append(familiar)

func handle_target_input():
	var target_type : BattleAction.TargetType = targeting_action.get_target_type()
	match target_type:
		BattleAction.TargetType.ANY_OPPONENT:
			handle_single_target_input()
		BattleAction.TargetType.ANY_ALLY:
			handle_single_target_input()
		BattleAction.TargetType.ANY_DEAD:
			pass
	if(Input.is_action_just_pressed("action_1")):
		play_sound(load("res://audio/effects/bell_quicker.ogg"))
		reset_input_phase()
		reset_show_status()
		queue_player_action()
	elif(Input.is_action_just_pressed("action_2")):
		reset_input_phase()
		play_sound(load("res://audio/effects/brush_snare.ogg"))

func handle_single_target_input():
	var current_target : Familiar
	if(targeted_familiars.size() == 0):
		current_target = targetable_familiars[0]
		targeted_familiars.append(current_target)
		update_sel_arrows()
	else:
		current_target = targeted_familiars[0]
		update_sel_arrows()
	if(Input.is_action_just_pressed("left") ||
	 Input.is_action_just_pressed("right")):
		play_sound(load("res://audio/effects/bell_first.ogg"))
		var index = targetable_familiars.find(current_target)
		if(Input.is_action_just_pressed("left")):
			index = index - 1
			if(index < 0):
				index = targetable_familiars.size() - 1
			current_target = targetable_familiars[index]
		elif(Input.is_action_just_pressed("right")):
			index = index + 1
			if(index >= targetable_familiars.size()):
				index = 0
			current_target = targetable_familiars[index]
		targeted_familiars.clear()
		targeted_familiars.append(current_target)
		update_sel_arrows()

func queue_player_action():
	var actor : Familiar = player_familiars[player_familiar_index]
	var action : BattleAction = targeting_action
	var targets : Array[Familiar] = targeted_familiars
	var new_action = ActionQueueItem.new(actor,action,targets)
	player_action_queue.append(new_action)
	advance_player_familiar_index()

func advance_player_familiar_index():
	player_familiar_index = player_familiar_index + 1
	while(player_familiar_index < player_familiars.size() &&
	player_familiars[player_familiar_index].is_dead()): #skip dead ones
		player_familiar_index = player_familiar_index + 1
	if(player_familiar_index >= player_familiars.size()):
		current_phase = BattlePhase.BATTLE
		player_familiar_index = 0

func target_process():
	handle_target_input()

func update_sel_arrows():
	hide_all_sel_arrows()
	for familiar in targeted_familiars:
		var slot : FamiliarSlot = familiar.get_parent()
		slot.show_select_arrow()

func hide_all_sel_arrows():
	for slot : FamiliarSlot in opponent_positions:
		slot.hide_select_arrow()
	for slot : FamiliarSlot in player_positions:
		slot.hide_select_arrow()
#endregion
#region Battle Phase
var current_battle_action : BattleAction
var current_actor : Familiar
var current_targets: Array[Familiar]
var first_action : bool = true

func battle_process():
	if(opponent_action_queue.size() == 0):
		get_opponent_actions()
		get_combined_action_queue()
		first_action = true
	elif(first_action):
		get_next_action()
		first_action = false
	else:
		run_actions_process()

func run_actions_process():
	if(!awaiting_input):
		current_battle_action.action_process(current_actor,current_targets)

func get_next_action():
	if(combined_action_queue.size() > 0):
		var current_action : ActionQueueItem = combined_action_queue.pop_front()
		current_battle_action = current_action.get_action()
		current_actor = current_action.get_actor()
		current_targets = current_action.get_targets()
	else:
		wait_timer.start(2.0)
		return_to_input_phase()

func return_to_input_phase():
	reset_show_status()
	reset_input_phase()
	player_action_queue.clear()
	opponent_action_queue.clear()
	player_familiar_index = 0

func get_combined_action_queue():
	combined_action_queue.clear()
	for opponent_action in opponent_action_queue:
		insert_into_combined_action_queue(opponent_action)
	for player_action in player_action_queue:
		insert_into_combined_action_queue(player_action)

func insert_into_combined_action_queue(insert_item : ActionQueueItem):
	var new_combined_action_queue : Array[ActionQueueItem] = []
	if(combined_action_queue.size() == 0):
		new_combined_action_queue.append(insert_item)
	else:
		var item_appended : bool = false
		#check if it is faster or as fast as anything else already in the queue
		for item : ActionQueueItem in combined_action_queue:
			if (item_appended || #if we've already inserted the item, just add the rest
			#otherwise, the given actor with higher speed acts first
			item.get_actor().get_speed() > insert_item.get_actor().get_speed()):
				new_combined_action_queue.append(item)
			#if speed of insert actor beats the speed of given actor, their action is inserted
			#before the action of given actor
			elif item.get_actor().get_speed() < insert_item.get_actor().get_speed():
				new_combined_action_queue.append(insert_item)
				new_combined_action_queue.append(item)
				item_appended = true
			#if they have equal speed, choose randomly between them
			elif(item.get_actor().get_speed() == insert_item.get_actor().get_speed()):
				if(randi_range(0,1.0) < 0.5 ): #coin toss
					new_combined_action_queue.append(insert_item)
					item_appended = true
				new_combined_action_queue.append(item)
		#if it wasn't faster than anything in the queue, add it last
		if(!item_appended):
			new_combined_action_queue.append(insert_item)
	combined_action_queue.clear()
	combined_action_queue.append_array(new_combined_action_queue)

func get_opponent_actions():
	for opponent : Familiar in opponent_familiars:
		if(opponent.is_dead()):
			continue
		else:
			#TODO: more complex decision making process
			#perhaps an call an overridable decision-making
			#function per familiar?
			var opponent_actions : Array[BattleAction] = opponent.get_actions()
			var acts_num = opponent_actions.size() - 1
			var chosen_action : BattleAction = opponent_actions[randi_range(0,acts_num)]
			var potential_targets : Array[Familiar] = get_opponent_targetable_familiars(chosen_action)
			var chosen_targets : Array[Familiar] = get_targets(chosen_action, potential_targets)
			var opponent_action_item := ActionQueueItem.new(opponent, chosen_action, chosen_targets)
			opponent_action_queue.append(opponent_action_item)

func get_targets(action : BattleAction,
potential_targets : Array[Familiar]) -> Array[Familiar]:
	var target_type : BattleAction.TargetType = action.get_target_type()
	var ret_array : Array[Familiar] = []
	match target_type:
		BattleAction.TargetType.ANY_OPPONENT:
			ret_array.append_array(opponent_select_single_target(potential_targets))
		BattleAction.TargetType.ANY_ALLY:
			ret_array.append_array(opponent_select_single_target(potential_targets))
		BattleAction.TargetType.ANY_DEAD:
			pass
	return ret_array

func opponent_select_single_target(potential_targets : Array[Familiar]) -> Array[Familiar]:
	var p_targets_num = potential_targets.size() - 1
	var chosen_target = potential_targets[randi_range(0,p_targets_num)]
	var ret_array : Array[Familiar] = [chosen_target]
	return ret_array

func get_opponent_targetable_familiars(action : BattleAction) -> Array[Familiar]:
	var target_type : BattleAction.TargetType = action.get_target_type()
	var opponent_targetable_familiars : Array[Familiar] = []
	match target_type:
		BattleAction.TargetType.NO_TARGET:
			pass
		BattleAction.TargetType.ANY_OPPONENT:
			for opponent in player_familiars:
				if(not opponent.is_dead()):
					opponent_targetable_familiars.append(opponent)
		BattleAction.TargetType.ANY_ALLY:
			for familiar in opponent_familiars:
				if(not familiar.is_dead()):
					opponent_targetable_familiars.append(familiar)
		BattleAction.TargetType.ANY_DEAD:
			pass
	return opponent_targetable_familiars

#endregion
#endregion
