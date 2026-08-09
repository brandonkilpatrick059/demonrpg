class_name GlobalGamestate extends Node

var states_map_keys : Array[String] = []
var states_map_values : Array[String] = []

func get_state_map_value(key : String) -> String:
	var key_index = states_map_keys.find(key)
	if(key_index < 0):
		return "NONE"
	else:
		return states_map_values[key_index]

func set_state_map_value(key : String, value : String):
	var key_index = states_map_keys.find(key)
	if(key_index < 0):
		states_map_keys.append(key)
		states_map_values.append(value)
	else:
		states_map_values.set(key_index,value)
