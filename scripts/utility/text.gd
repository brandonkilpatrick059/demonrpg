class_name  Text extends Node

@export var language_map : Array[String] =[]
@export_multiline var text : Array[String] = []
@export var script_node : Node = null

func get_text(lang_code : String) -> String:
	var index = language_map.find(lang_code)
	return text[index]

func get_script_node():
	return script_node
