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

var battle_end_victory : Array[String] = [
	"Nothing remains of your enemies.",
	"Your enemies are defeated.",
	"You have destroyed your enemies."
]

var battle_end_loss : Array[String] = [
	"You will soon die."
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
			ret_string = random_string(battle_end_victory)
		"end_defeat":
			ret_string = random_string(battle_end_loss)
	return ret_string

func random_string(from_array : Array[String]) -> String:
	var index = randi_range(0,from_array.size()-1)
	var ret_string : String = from_array[index]
	return ret_string
