class_name TextQueue extends Node

@export var texts : Array[Text] = []

func get_texts() -> Array[Text]:
	return texts

func get_scripts() -> Array[Node]:
	var scripts : Array[Node] =[]
	for text : Text in texts:
		if text.get_script_node() != null:
			scripts.append(text.get_script_node())
		else:
			scripts.append(null)
	return scripts

func get_dummy_dark_texts() -> Array[bool]:
	var dummy : Array[bool] =[]
	for text : Text in texts:
		dummy.append(false)
	return dummy
