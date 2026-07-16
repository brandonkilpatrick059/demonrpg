class_name BattleText extends Node

var intro_single_eng : Array[String] = [
	"A figure emerges from shadow..."
]

var intro_mult_eng : Array[String] = [
	"Figures emerge from shadow..."
]

func get_text(code : String) -> String:
	var ret_string : String = ""
	match code:
		"intro_single":
			ret_string = random_string(intro_single_eng)
		"intro_mult":
			ret_string = random_string(intro_mult_eng)
	return ret_string

func random_string(from_array : Array[String]) -> String:
	var index = randi_range(0,from_array.size()-1)
	var ret_string : String = from_array[index]
	return ret_string
