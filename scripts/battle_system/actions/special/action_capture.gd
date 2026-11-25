extends BattleAction

var announced_capture : bool = false
var made_capture : bool = false
var made_switch : bool = false

var battle_sys_ref : BattleSystemManager

var success_english : String = "You bring the [TARGET] into your dominion."
var announcement_english : String = "The pact is sealed..."

func get_announcement() -> String:
	return announcement_english

func get_success(target : Familiar) -> String:
	var ret_string = success_english.replace("[TARGET]",target.get_familiar_name())
	return ret_string
	
var timer := Timer.new()

func _ready() -> void:
	action_name = "CAPTURE"
	target_type = TargetType.NO_TARGET
	damage_type = DamageType.NONE
	timer.one_shot = true
	add_child(timer)

func clean_up():
	announced_capture = false
	made_capture = false
	made_switch = false

func visual_effects(target : Familiar):
	target.modulate = Color(1,1,1,0)
	var capture_effect = load("res://battle/effects/capture_effect.tscn").instantiate()
	battle_sys_ref.add_child(capture_effect)
	capture_effect.global_position = target.global_position
	battle_sys_ref.play_sound(load("res://audio/effects/capture.ogg"))

func exit_action(full_action_executed : bool = false):
	if full_action_executed:
		battle_sys_ref.start_wait_timer(0.5)
	battle_sys_ref.get_next_action()
	clean_up()

func switch_to_player_familiars(target : Familiar):
	var fade_in_node = load("res://utility/faders/capture_fade.tscn").instantiate()
	target.add_child(fade_in_node)
	battle_sys_ref.switch_familiar_to_player_familiars(target)
	var player : Player = get_tree().get_first_node_in_group("player")
	var charms : int = player.get_pentacle_charms() - 1
	player.set_pentacle_charms(charms)
	battle_sys_ref.play_sound(load("res://audio/effects/bell_full_low.ogg"))

func action_process(actor : Familiar, targets : Array[Familiar]):
	battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
	if(!announced_capture):
		if(targets.size() > 0 and targets[0] != null):
			var announcement : String = get_announcement()
			battle_sys_ref.center_message()
			battle_sys_ref.play_sound(load("res://audio/effects/contract.ogg"))
			battle_sys_ref.play_messages([announcement])
			announced_capture = true
		else:
			exit_action()
	elif(!made_capture):
		if(targets.size() > 0 and targets[0] != null):
			timer.start(1.5)
			var target : Familiar = targets[0]
			target.set_health_percentage(0.75)
			visual_effects(target)
			made_capture = true
		else:
			exit_action()
	elif(!made_switch):
		if(targets.size() > 0 and targets[0] != null):
			#if(!battle_sys_ref.is_waiting()):
			#if(timer.is_stopped()):
			switch_to_player_familiars(targets[0])
			var success : String = get_success(targets[0])
			battle_sys_ref.play_messages([success])
			made_switch = true
		else:
			exit_action()
	else:
		var full_action_exectued : bool = true
		exit_action(full_action_exectued)
