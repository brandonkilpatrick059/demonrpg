extends Node

@export var text_queues : Array[TextQueue] = []
@export var no_loop : bool = false

var current_index = 0

func advance_next_text_queue():
	if(current_index + 1 <= text_queues.size() - 1):
		current_index = current_index + 1
	else:
		if not no_loop:
			current_index = 0

func get_current_texts() -> Array[String]:
	var textQueue : TextQueue = text_queues[current_index]
	var texts : Array[Text] = textQueue.get_texts()
	var ret_array : Array[String] = []
	for text in texts:
		ret_array.append(text.get_text("english"))
	return ret_array

func get_current_scripts() -> Array[Node]:
	var textQueue : TextQueue = text_queues[current_index]
	var texts : Array[Text] = textQueue.get_texts()
	var ret_array : Array[Node] = []
	for text in texts:
		ret_array.append(text.get_script_node())
	return ret_array

func get_dummy_dark_texts() -> Array[bool]:
	var textQueue : TextQueue = text_queues[current_index]
	return textQueue.get_dummy_dark_texts()
	
