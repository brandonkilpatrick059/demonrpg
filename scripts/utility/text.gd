class_name  Text extends Node

@export var language_map : Array[String] =[]
@export_multiline var text : Array[String] = []

func get_text(lang_code : String) -> String:
	var index = language_map.find(lang_code)
	return text[index]
