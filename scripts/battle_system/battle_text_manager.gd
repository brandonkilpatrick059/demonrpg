class_name BattleText extends Node

var intro_single_eng : Array[String] = [
	"A figure emerges from shadow..."
]

var intro_mult_eng : Array[String] = [
	"Figures emerge from shadow..."
]

var no_targets_eng : Array[String] = [
	"There are no targets."
]

var battle_end_victory_eng : Array[String] = [
	"Nothing remains."
]

var battle_end_loss_eng : Array[String] = [
	"You will soon die."
]

var capture_available_eng : Array[String] = [
	"The [TARGET] is weak..."
]

var player_deploy_eng : Array[String] = [
	"You are alone and defenseless..."
]

var player_withdraw_eng : Array[String] = [
	"Your familiars defend you."
]

var run_eng : Array[String] = [
	"You manage to escape."
]

func get_text(code : String) -> String:
	var ret_string : String = ""
	match code:
		"intro_single":
			ret_string = random_string(intro_single_eng)
		"intro_mult":
			ret_string = random_string(intro_mult_eng)
		"no_targets":
			ret_string = random_string(no_targets_eng)
		"end_victory":
			ret_string = random_string(battle_end_victory_eng)
		"end_defeat":
			ret_string = random_string(battle_end_loss_eng)
		"capture_available":
			ret_string = random_string(capture_available_eng)
		"player_deploy":
			ret_string = random_string(player_deploy_eng)
		"player_withdraw":
			ret_string = random_string(player_withdraw_eng)
		"run":
			ret_string = random_string(run_eng)
	return ret_string

func random_string(from_array : Array[String]) -> String:
	var index = randi_range(0,from_array.size()-1)
	var ret_string : String = from_array[index]
	return ret_string
