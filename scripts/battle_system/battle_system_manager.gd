class_name BattleSystemManager extends Node2D

@onready var action_menu : BattleActionMenu = $BattleActionMenu
@onready var message : BattleMessage = $BattleMessage
@onready var status : BattleStatus = $BattleStatus
@onready var hp_gauge : HPGauge = $hp_gauge
@onready var capture_dialog : CaptureDialog = $CaptureDialog

@export var opponent_familiars : Array[Familiar] = []
@export var player_familiars : Array[Familiar] = []
@export var music : AudioStream = null

var text := BattleText.new()

@onready var action_capture = $ActionCapture

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
var input_gate_timer := Timer.new()

var music_player := AudioStreamPlayer.new()
var audio_players : Array[AudioStreamPlayer] = []

#STATE INFO
enum BattlePhase {START,INPUT,INPUT_TARGET,INPUT_CAPTURE,BATTLE,END}
var current_phase : BattlePhase = BattlePhase.START
var awaiting_input : bool = false
var familiars_initialized : bool = false
var input_phase_entered : bool = false
var battle_closed : bool = false

var player_deployed : bool = false

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
var special_action_queue : Array[ActionQueueItem] = []

func _ready() -> void:
	wait_timer.one_shot = true
	input_gate_timer.one_shot = true
	add_child(wait_timer)
	add_child(input_gate_timer)
	hide_all_interface()
	set_up_audio()
	add_to_group("battle_system")
	if(music != null):
		play_music(music)
	wait_timer.start(1.5)

func set_familiars(set_player_familiars : Array[Familiar], 
set_opponent_familiars : Array[Familiar]):
	player_familiars = set_player_familiars
	opponent_familiars = set_opponent_familiars
	initialize_familiars()

func get_adjacent_familiars(to_familiar : Familiar, left_only : bool = false) -> Array[Familiar]:
	var adjacent_familiars : Array[Familiar] = []
	var index = 0
	if(to_familiar.is_hostile()):
		index = opponent_positions.find(to_familiar.get_parent())
		var left_index = index - 1
		var right_index = index + 1
		if(left_index >= 0):
			if(opponent_positions[left_index].get_child_count() > 0):
				adjacent_familiars.append(opponent_positions[left_index].get_child(0))
		if(right_index < opponent_positions.size() && not left_only):
			if(opponent_positions[right_index].get_child_count() > 0):
				adjacent_familiars.append(opponent_positions[right_index])
	else:
		index = player_positions.find(to_familiar.get_parent())
		var left_index = index - 1
		var right_index = index + 1
		if(left_index >= 0):
			if(player_positions[left_index].get_child_count() > 0):
				adjacent_familiars.append(player_positions[left_index].get_child(0))
		if(right_index < player_positions.size() && not left_only):
			if(player_positions[right_index].get_child_count() > 0):
				adjacent_familiars.append(player_positions[right_index].get_child(0))
	return adjacent_familiars
	

func fade_in():
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	var fade_to = Color(1,1,1,0)
	fade_node.set_target_modulate(fade_to,0.2,0.2)
	$fade_to_black.add_child(fade_node)

func fade_out():
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	var fade_to = Color(1,1,1,1)
	fade_node.set_target_modulate(fade_to,0.2,0.2)
	$fade_to_black.add_child(fade_node)

func set_up_audio():
	add_child(music_player)	
	var index : int = 0
	var num_sound_players = 8
	while(index < num_sound_players):
		var new_sound_player := AudioStreamPlayer.new()
		add_child(new_sound_player)
		audio_players.append(new_sound_player)
		index = index + 1

func play_music(sound : AudioStream):
	music_player.stream = sound
	music_player.play()

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
	capture_dialog.visible = false

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
		familiar.modulate.a = 0.95
		familiar.mark_hostile()
		familiar.set_current_energy(0)
		familiar.reset_energy()
		familiar.set_active()
	
	if(player_familiars.size() == 0):
		deploy_player()
	else:
		index = 0
		for familiar in player_familiars:
			familiar.reparent(player_positions[index])
			familiar.position= Vector2(0,0)
			familiar.set_current_energy(0)
			familiar.reset_energy()
			familiar.set_active()
			index = index + 1
	
	familiars_initialized = true

func play_messages(text_queue : Array[String]):
	message.queue_text(text_queue)
	awaiting_input = true

func start_wait_timer(time : float):
	wait_timer.start(time)

func is_waiting() -> bool:
	return wait_timer.is_stopped()

func switch_familiar_to_player_familiars(familiar : Familiar):
	opponent_familiars.erase(familiar)
	player_familiars.append(familiar)
	for slot in player_positions:
		if(slot.get_child_count() == 0):
			familiar.reparent(slot)
			familiar.position = Vector2(0,0)
			familiar.arrange_buffs()
			break
	familiar.mark_friendly()

func add_capture_action(familiar : Familiar):
	var new_combined_action_queue : Array[ActionQueueItem]
	for action_item : ActionQueueItem in combined_action_queue:
		if(action_item.get_actor() != familiar and
		not action_item.get_targets().has(familiar)):
			new_combined_action_queue.append(action_item)
	combined_action_queue.clear()
	combined_action_queue.append_array(new_combined_action_queue)
	var dummy_actor := Familiar.new()
	var capture_queue_item := ActionQueueItem.new(dummy_actor,action_capture,[familiar])
	combined_action_queue.push_front(capture_queue_item)
	capture_accepted = false

func set_capture_accepted():
	capture_accepted = true

func append_special_action_queue(action : ActionQueueItem):
	special_action_queue.append(action)

#region Process
func _physics_process(delta: float) -> void:
	if(familiars_initialized):
		process_battle()

func process_battle():
	clean_familiars()
	if(wait_timer.is_stopped()):
		match(current_phase):
			BattlePhase.START:
				start_process()
			BattlePhase.INPUT:
				input_process()
			BattlePhase.INPUT_CAPTURE:
				offer_capture_process()
			BattlePhase.INPUT_TARGET:
				target_process()
			BattlePhase.BATTLE:
				battle_process()
			BattlePhase.END:
				end_process()

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
		var num_actions : int = current_familiar.get_num_actions()
		if(current_familiar != null && not current_familiar.is_dead()):
			if(not input_phase_entered):
				update_buffs()
				input_phase_entered = true
			elif(familiar_actions_in_queue(current_familiar) != num_actions):
				if(not status_shown):
					show_status(current_familiar)
					status_shown = true
				elif(status_shown && not awaiting_input):
					show_action_menu(current_familiar)
					awaiting_input = true
			else:
				advance_player_familiar_index()
		else:
			advance_player_familiar_index()
	else:
		advance_player_familiar_index()

func show_status(familiar : Familiar): 
	status.global_position = familiar.global_position + Vector2(0,-64)
	status.set_name_label(familiar.get_familiar_name())
	var current_hp = familiar.get_current_hp()
	var max_hp = familiar.get_max_hp()
	var hp_fraction : float = float(current_hp) / float(max_hp)
	var dont_animate : bool = true
	status.set_hp_gauge(hp_fraction,current_hp,max_hp,dont_animate)
	status.set_energy_gauge(familiar.get_current_energy())
	if(familiar.get_num_actions() > 1):
		var current_turns = familiar.get_actions_taken() + 1
		status.set_num_turns_label(current_turns,familiar.get_num_actions())
	status.set_active()
	awaiting_input = true

func show_action_menu(familiar : Familiar):
	if(not familiar.is_in_group("player_familiar") and
	side_is_dead(opponent_familiars)):
		action_menu.set_actions([$ActionPass,$ActionFeed])
	else:
		action_menu.set_actions(familiar.get_actions())
	var height = -16 - action_menu.get_height()
	action_menu.global_position = familiar.global_position + Vector2(0,height)
	action_menu.set_energy_gauge(familiar.get_current_energy())
	if(familiar.get_num_actions() > 1):
		var current_turns = familiar.get_actions_taken() + 1
		action_menu.set_num_turns_label(current_turns,familiar.get_num_actions())
	action_menu.set_active()

func reset_show_status():
	status_shown = false
	awaiting_input =false

func familiar_in_action_queue(familiar : Familiar) -> bool:
	for action_item : ActionQueueItem in player_action_queue:
		if(action_item.actor == familiar):
			return true
	return false

func familiar_actions_in_queue(familiar : Familiar) -> int:
	var num_actions : int = 0
	for action_item : ActionQueueItem in player_action_queue:
		if(action_item.actor == familiar):
			num_actions = num_actions + 1
	return num_actions
#endregion
#region Input Capture Phase
var begin_capture_offered : bool = false
var capture_offered : bool = false
var target_capture : Familiar
var capture_accepted : bool = false

func offer_capture_process():
	if(not begin_capture_offered):
		target_capture = can_offer_capture()
		var target_name : String = target_capture.get_familiar_name()
		var capture_available : String = text.get_text("capture_available")
		capture_available = capture_available.replace("[TARGET]",target_name)
		play_messages([capture_available])
		begin_capture_offered = true
	elif(begin_capture_offered 
	and not capture_offered 
	and not awaiting_input):
		capture_dialog.set_target(target_capture)
		capture_dialog.set_active()
		start_awaiting_input()
		capture_offered = true
	elif(begin_capture_offered 
	and capture_offered 
	and not awaiting_input):
		begin_capture_offered = false
		capture_offered = false
		current_phase = BattlePhase.BATTLE
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
	if(targeting_action.get_target_type() != BattleAction.TargetType.NO_TARGET &&
	targetable_familiars.size() == 0):
		var no_targets : String = text.get_text("no_targets")
		play_messages([no_targets])
		reset_input_phase()

func reset_input_phase():
	hide_all_sel_arrows()
	current_phase = BattlePhase.INPUT

func get_targetable_familiars(action : BattleAction):
	targetable_familiars.clear()
	targeted_familiars.clear()
	var target_type : BattleAction.TargetType = action.get_target_type()
	var unsorted_targets : Array[Familiar]
	match target_type:
		BattleAction.TargetType.NO_TARGET:
			pass
		BattleAction.TargetType.ANY_OPPONENT:
			for opponent in opponent_familiars:
				if(not opponent.is_dead()):
					unsorted_targets.append(opponent)
		BattleAction.TargetType.ANY_ALLY:
			for familiar in player_familiars:
				if(not familiar.is_dead()):
					unsorted_targets.append(familiar)
		BattleAction.TargetType.TWO_ADJACENT_OPPONENT:
			for opponent in opponent_familiars:
				if(not opponent.is_dead()):
					unsorted_targets.append(opponent)
		BattleAction.TargetType.ANY_DEAD:
			for opponent in opponent_familiars:
				if(opponent.is_dead()):
					unsorted_targets.append(opponent)
			for familiar in player_familiars:
				if(familiar.is_dead()):
					unsorted_targets.append(familiar)
		BattleAction.TargetType.ANY_BUT_SELF:
			for opponent in opponent_familiars:
				unsorted_targets.append(opponent)
			for familiar in player_familiars:
				if(familiar != player_familiars[player_familiar_index]):
					unsorted_targets.append(familiar)
	if(unsorted_targets.size() > 0):
		var sorted_targets : Array[Familiar] = []
		while(unsorted_targets.size() > 0):
			var sort_target = unsorted_targets.pop_back()
			if(sorted_targets.size() == 0):
				sorted_targets.append(sort_target)
			else:
				var index = 0
				while(index < sorted_targets.size()):
					var sorted_x = sorted_targets[index].global_position.x
					if(sort_target.global_position.x <= sorted_x):
						break
					index = index + 1
				sorted_targets.insert(index,sort_target)
		targetable_familiars.append_array(sorted_targets)

func handle_target_input():
	var target_type : BattleAction.TargetType = targeting_action.get_target_type()
	match target_type:
		BattleAction.TargetType.ANY_OPPONENT:
			handle_single_target_input()
		BattleAction.TargetType.ANY_ALLY:
			handle_single_target_input()
		BattleAction.TargetType.ANY_BUT_SELF:
			handle_single_target_input()
		BattleAction.TargetType.TWO_ADJACENT_OPPONENT:
			handle_two_adjacent_target_input()
		BattleAction.TargetType.NO_TARGET:
			select_targets()
	if(input_gate_timer.is_stopped()):
		if(Input.is_action_just_pressed("action_1")):
			select_targets()
		elif(Input.is_action_just_pressed("action_2")):
			reset_input_phase()
			play_sound(load("res://audio/effects/brush_snare.ogg"))

func select_targets():
	play_sound(load("res://audio/effects/bell_quicker.ogg"))
	reset_input_phase()
	reset_show_status()
	queue_player_action()
	input_gate_timer.start(0.5)

func handle_single_target_input():
	var current_target : Familiar
	if(targeted_familiars.size() == 0 &&
	targetable_familiars.size() > 0):
		current_target = targetable_familiars[0]
		targeted_familiars.append(current_target)
		update_sel_arrows()
	elif(targetable_familiars.size() > 0):
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

func handle_two_adjacent_target_input():
	var current_target : Familiar
	if(targeted_familiars.size() == 0 &&
	targetable_familiars.size() > 0):
		current_target = targetable_familiars[1]
		targeted_familiars.append(current_target)
		var left_familiar = get_adjacent_familiars(current_target,true)
		targeted_familiars.append_array(left_familiar)
		update_sel_arrows()
	elif(targetable_familiars.size() > 0):
		current_target = targeted_familiars[0]
		var left_familiar = get_adjacent_familiars(current_target,true)
		targeted_familiars.append_array(left_familiar)
		update_sel_arrows()
	if(Input.is_action_just_pressed("left") ||
	 Input.is_action_just_pressed("right")):
		play_sound(load("res://audio/effects/bell_first.ogg"))
		var index = targetable_familiars.find(current_target)
		if(Input.is_action_just_pressed("left")):
			index = index - 1
			if(index < 1):
				index = targetable_familiars.size() - 1
			current_target = targetable_familiars[index]
		elif(Input.is_action_just_pressed("right")):
			index = index + 1
			if(index >= targetable_familiars.size()):
				index = 1
			current_target = targetable_familiars[index]
		targeted_familiars.clear()
		targeted_familiars.append(current_target)
		var left_familiar : Array[Familiar] = get_adjacent_familiars(current_target,true)
		targeted_familiars.append_array(left_familiar)
		update_sel_arrows()

func queue_player_action():
	var actor : Familiar = player_familiars[player_familiar_index]
	var action : BattleAction = targeting_action
	var targets : Array[Familiar] = targeted_familiars
	action.pay_energy_cost(actor)
	var new_action = ActionQueueItem.new(actor,action,targets)
	player_action_queue.append(new_action)
	advance_player_familiar_index()
 
func advance_player_familiar_index():
	var current_familiar : Familiar = player_familiars[player_familiar_index]
	var actions_taken : int = current_familiar.get_actions_taken()
	var num_actions : int = current_familiar.get_num_actions()
	if(actions_taken < num_actions):
		current_familiar.action_taken()
	else:
		current_familiar.reset_actions_taken()
		player_familiar_index = player_familiar_index + 1
		while(player_familiar_index < player_familiars.size() &&
		player_familiars[player_familiar_index].is_dead()): #skip dead ones
			player_familiar_index = player_familiar_index + 1
		if(player_familiar_index >= player_familiars.size()):
			if(can_offer_capture() != null):
				current_phase = BattlePhase.INPUT_CAPTURE
			else:
				current_phase = BattlePhase.BATTLE
			player_familiar_index = 0

func can_offer_capture() -> Familiar:
	var player : Player = get_tree().get_first_node_in_group("player")
	var pentacles = player.get_pentacle_charms()
	var null_familiar : Familiar = null
	if(pentacles > 0 && player_familiars.size() < 4):
		for familiar in opponent_familiars:
			var hp_fraction : int = familiar.get_capture_range()
			var current_hp = familiar.get_current_hp()
			if(current_hp <= hp_fraction and
			not familiar.is_dead() and
			not familiar.is_capture_offered()):
				return familiar
	return null_familiar

func target_process():
	handle_target_input()

func update_sel_arrows():
	hide_all_sel_arrows()
	for familiar in targeted_familiars:
		var slot : FamiliarSlot = familiar.get_parent()
		slot.show_select_arrow()
		if(familiar.is_dead()):
			var stat : String = familiar.get_stat_increase()
			var value : int = familiar.get_stat_increase_value()
			var label = str(str(stat," + "),value)
			slot.show_upgrade_label(label)

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
var have_combined_queue : bool = false

func battle_process():
	if(opponent_familiars.size() == 0 or player_is_dead()):
		if(player_is_dead() && not player_deployed):
			deploy_player()
		elif(opponent_familiars.size() == 0 || 
		(player_is_dead() && player_deployed)):
			end_battle()
	elif(opponent_is_dead() && player_deployed):
		end_battle()
	elif(count_living_on_side(player_familiars) > 1 && player_deployed):
		withdraw_player()
	elif(opponent_action_queue.size() == 0 && not opponent_is_dead()):
		get_opponent_actions()
	elif(not have_combined_queue):
		get_combined_action_queue()
		have_combined_queue = true
		first_action = true
	elif(first_action):
		get_next_action()
		first_action = false
	else:
		run_actions_process()

func deploy_player():
	if player_positions[1].get_child_count() > 0:
		player_positions[1].get_child(0).queue_free()
	var player_familiar = load("res://familiars/L0_girl.tscn").instantiate()
	player_familiars.append(player_familiar)
	player_positions[1].add_child(player_familiar)
	player_familiar.set_active()
	player_familiar.position = Vector2(0,0)
	player_deployed = true
	if(battle_started):
		play_messages([text.get_text("player_deploy")])
	clean_familiars()

func withdraw_player():
	player_deployed = false
	player_familiars.erase(player_positions[1].get_child(0))
	player_positions[1].get_child(0).queue_free()
	if(battle_started && current_phase != BattlePhase.END):
		play_messages([text.get_text("player_withdraw")])
	clean_familiars()

func end_battle():
	current_phase = BattlePhase.END

func run_away():
	end_battle()
	close_battle(true)

func fader_is_fading() -> bool:
	var is_fading : bool = false
	if($fade_to_black.get_child_count() > 0):
		is_fading = true
	return is_fading

func player_is_dead() -> bool:
	return side_is_dead(player_familiars)

func opponent_is_dead() -> bool:
	return side_is_dead(opponent_familiars)

func count_living_on_side(side_familiars : Array[Familiar]) -> int:
	var count : int = 0
	for familiar in side_familiars:
		if(not familiar.is_dead()):
			count = count + 1
	return count

func side_is_dead(side_familiars : Array[Familiar]) -> bool:
	var is_dead = true
	if(side_familiars.size() == 0):
		is_dead = true
		return is_dead
	else:
		for familiar in side_familiars:
			if(not familiar.is_dead()):
				is_dead = false
				return is_dead
	return is_dead

func run_actions_process():
	if(!awaiting_input && current_battle_action != null):
		position_message()
		current_battle_action.action_process(current_actor,current_targets)
	elif(current_battle_action == null):
		get_next_action()

func center_message():
	message.global_position = global_position

func position_message():
	if(current_actor != null):
		var slot = current_actor.get_parent()
		var slot_index : int = 0
		if(current_actor.is_hostile()):
			slot_index = opponent_positions.find(slot)
		else:
			slot_index = player_positions.find(slot)
		var position_at_slot : int = 0
		match slot_index:
			0:
				position_at_slot = 3
			1:
				position_at_slot = 3
			2:
				position_at_slot = 0
			3:
				position_at_slot = 0
		var pos_slot : Node2D
		if(current_actor != null &&
		current_targets != null &&
		current_targets.size() > 0 &&
		current_targets[0] != null):
			if((current_actor.is_hostile() &&
			not current_targets[0].is_hostile()) ||
			(not current_actor.is_hostile() &&
			not current_targets[0].is_hostile())):
				pos_slot = opponent_positions[position_at_slot]
			elif((not current_actor.is_hostile() &&
			current_targets[0].is_hostile()) ||
			(current_actor.is_hostile() &&
			current_targets[0].is_hostile())):
				pos_slot = player_positions[position_at_slot]
			message.global_position = pos_slot.global_position

func reset_message_position():
	message.global_position = global_position

func get_next_action():
	update_buff_positions()
	if(combined_action_queue.size() > 0):
		var current_action : ActionQueueItem = combined_action_queue.pop_front()
		while(current_action == null || 
			current_action.get_actor() == null ||
			current_action.get_actor().is_dead()):
			current_action = combined_action_queue.pop_front()
			if(combined_action_queue.size() == 0):
				wait_timer.start(1.0)
				return_to_input_phase()
				break
		if(current_action != null):
			current_battle_action = current_action.get_action()
			current_actor = current_action.get_actor()
			current_targets = current_action.get_targets()
			current_battle_action.clean_up()
			#get a new target for opponent if their intended
			#target has died
			if((current_actor.is_hostile() &&
			current_targets.size() == 1) &&
			(current_targets[0] == null ||
			current_targets[0].is_dead())):
				var potential_targets: Array[Familiar] = []
				var actor = current_action.get_actor()
				var valid_targets = get_opponent_targetable_familiars(actor,current_battle_action)
				potential_targets.append(valid_targets)
				var new_target = randi_range(0,potential_targets.size())
				current_targets = [new_target]
				
	elif(combined_action_queue.size() == 0):
		wait_timer.start(1.0)
		return_to_input_phase()

func update_buffs():
	for familiar in player_familiars:
		familiar.update_buffs()
	for familiar in opponent_familiars:
		familiar.update_buffs()

func update_buff_positions():
	for familiar in player_familiars:
		familiar.arrange_buffs()
	for familiar in opponent_familiars:
		familiar.arrange_buffs()

func clean_familiars():
	var new_player_familiars : Array[Familiar] = []
	for familiar in player_familiars:
		if(familiar != null):
			new_player_familiars.append(familiar)
	var new_opponent_familiars : Array[Familiar] = []
	for familiar in opponent_familiars:
		if(familiar != null):
			new_opponent_familiars.append(familiar)
	player_familiars.clear()
	player_familiars.append_array(new_player_familiars)
	opponent_familiars.clear()
	opponent_familiars.append_array(new_opponent_familiars)

func return_to_input_phase():
	reset_show_status()
	reset_input_phase()
	increment_all_energies()
	player_action_queue.clear()
	opponent_action_queue.clear()
	player_familiar_index = 0
	input_phase_entered = false
	have_combined_queue = false

func increment_all_energies():
	increment_energies(player_familiars)
	increment_energies(opponent_familiars)

func increment_energies(familiars : Array[Familiar]):
	for familiar in familiars:
		if(familiar != null && not familiar.is_dead()):
			var energy = familiar.get_current_energy()
			if(familiar.energy_is_depleted()):
				familiar.reset_energy()
			elif(energy < 4):
				familiar.set_current_energy(energy + 1)

func get_combined_action_queue():
	combined_action_queue.clear()
	for opponent_action in opponent_action_queue:
		insert_into_combined_action_queue(opponent_action)
	for player_action in player_action_queue:
		insert_into_combined_action_queue(player_action)
	if(special_action_queue.size() > 0):
		while(special_action_queue.size() > 0):
			var special_action = special_action_queue.pop_front()
			combined_action_queue.append(special_action)
	if(capture_accepted):
		add_capture_action(target_capture)

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
				if(not new_combined_action_queue.has(insert_item)):
					new_combined_action_queue.append(insert_item)
					item_appended = true
				new_combined_action_queue.append(item)
			#if they have equal speed, choose randomly between them
			elif(item.get_actor().get_speed() == insert_item.get_actor().get_speed()):
				if(randi_range(0.0,1.0) < 0.5 ): #coin toss
					if(not new_combined_action_queue.has(insert_item)):
						new_combined_action_queue.append(insert_item)
						item_appended = true
				new_combined_action_queue.append(item)
		#if it wasn't faster than anything in the queue, add it last
		if(!item_appended && not new_combined_action_queue.has(insert_item)):
			new_combined_action_queue.append(insert_item)
	combined_action_queue.clear()
	combined_action_queue.append_array(new_combined_action_queue)

func get_opponent_actions():
	for opponent : Familiar in opponent_familiars:
		if(opponent.is_dead()):
			continue
		else:
			while(opponent.get_actions_taken() < opponent.get_num_actions()):
				var opponent_actions : Array[BattleAction] = opponent.get_actions()
				var potential_actions : Array[BattleAction] = []
				#opponents should only choose actions where there are valid targets
				for action in opponent_actions:
					if(get_opponent_targetable_familiars(opponent, action).size() > 0 &&
					opponent.current_energy >= action.get_energy_cost()):
						potential_actions.append(action)
				var chosen_action : BattleAction
				var cadence_action : BattleAction = opponent.get_next_action()
				if(cadence_action in potential_actions):
					chosen_action = cadence_action
				else:
					chosen_action = get_randomized_action(potential_actions)
				var potential_targets : Array[Familiar]
				potential_targets = get_opponent_targetable_familiars(opponent,chosen_action)
				var chosen_targets : Array[Familiar] = get_targets(chosen_action, potential_targets)
				var opponent_action_item := ActionQueueItem.new(opponent, chosen_action, chosen_targets)
				opponent_action_queue.append(opponent_action_item)
				opponent.action_taken()
			opponent.reset_actions_taken()

func get_randomized_action(potential_actions : Array[BattleAction]) -> BattleAction:
	var chosen_action : BattleAction
	var action_chosen : bool = false
	#try rolling for each action
	for action : BattleAction in potential_actions:
		var roll = randf_range(0.0,1.0)
		if roll < action.get_choice_weight():
			action_chosen = true
			chosen_action = action
	#if we didn't roll one, just take the highest
	if(not action_chosen):
		for action : BattleAction in potential_actions:
			if(chosen_action == null):
				chosen_action = action
			else:
				if action.get_choice_weight() > chosen_action.get_choice_weight():
					chosen_action = action
	return chosen_action

func get_targets(action : BattleAction,
potential_targets : Array[Familiar]) -> Array[Familiar]:
	var target_type : BattleAction.TargetType = action.get_target_type()
	var ret_array : Array[Familiar] = []
	match target_type:
		BattleAction.TargetType.ANY_OPPONENT:
			ret_array.append_array(opponent_select_single_target(potential_targets))
		BattleAction.TargetType.ANY_ALLY:
			ret_array.append_array(opponent_select_single_target(potential_targets))
		BattleAction.TargetType.TWO_ADJACENT_OPPONENT:
			ret_array.append_array(opponent_select_two_adjacent_targets(potential_targets))
		BattleAction.TargetType.ANY_BUT_SELF:
			ret_array.append_array(opponent_select_single_target(potential_targets))
	return ret_array

func opponent_select_single_target(potential_targets : Array[Familiar]) -> Array[Familiar]:
	var p_targets_num = potential_targets.size() - 1
	var chosen_target = potential_targets[randi_range(0,p_targets_num)]
	var ret_array : Array[Familiar] = [chosen_target]
	return ret_array

func opponent_select_two_adjacent_targets(potential_targets : Array[Familiar]) -> Array[Familiar]:
	var index = 0
	#prefer to return two adjacent targets if possible
	var preferred_target_indexes : Array[int]
	for target in potential_targets:
		var left_adjacent : Array[Familiar] = []
		left_adjacent.append_array(get_adjacent_familiars(target,true))
		if(left_adjacent.size() > 0 && not left_adjacent[0].is_dead()):
			preferred_target_indexes.append(index)
		index = index + 1
	var target_index = 0
	if(preferred_target_indexes.size() > 0):
		target_index = preferred_target_indexes[randi_range(0,preferred_target_indexes.size()-1)]
	else:
		target_index = randi_range(0,potential_targets.size())
	var ret_array : Array[Familiar] = []
	var root_target : Familiar = potential_targets[target_index]
	ret_array.append(root_target)
	ret_array.append_array(get_adjacent_familiars(root_target,true))
	return ret_array

func get_opponent_targetable_familiars(actor : Familiar, action : BattleAction) -> Array[Familiar]:
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
		BattleAction.TargetType.TWO_ADJACENT_OPPONENT:
			for opponent in player_familiars:
				if(not opponent.is_dead()):
					opponent_targetable_familiars.append(opponent)
		BattleAction.TargetType.ANY_BUT_SELF:
			for opponent in player_familiars:
				opponent_targetable_familiars.append(opponent)
			for familiar in opponent_familiars:
				if(familiar != actor):
					opponent_targetable_familiars.append(familiar)
	return opponent_targetable_familiars

#endregion
#region End Phase
var waiting_to_fade : bool = false
func end_process():
	if(not battle_closed):
		close_battle()
	elif(battle_closed and not awaiting_input):
		awaiting_input = true
		waiting_to_fade = true
		fade_out()
	elif(waiting_to_fade and not fader_is_fading()):
		if(player_deployed):
			withdraw_player()
		var player : Player = get_tree().get_first_node_in_group("player")
		player.end_battle(player_familiars)

func close_battle(ran_away = false):
	message.global_position = global_position
	if(not ran_away):
		var victory : bool = not player_is_dead()
		if(victory):
			var victory_message : String = text.get_text("end_victory")
			play_messages([victory_message])
		else:
			var defeat_message : String = text.get_text("end_defeat")
			play_messages([defeat_message])
		battle_closed = true
	else:
		var run_message : String = text.get_text("run")
		play_messages([run_message])
		battle_closed = true
#endregion
#endregion
