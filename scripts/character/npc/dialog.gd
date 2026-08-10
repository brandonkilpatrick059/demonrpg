extends Node

@export var text_queues : Array[TextQueue] = []

var current_index = 0

func get_current_text() -> Array[String]:
	var textQueue : TextQueue = text_queues[current_index]
	var texts : Array[Text] = textQueue.get_texts()
	var ret_array : Array[String] = []
	for text in texts:
		ret_array.append(text.get_text("english"))
	if(current_index + 1 <= text_queues.size() - 1):
		current_index = current_index + 1
	else:
		current_index = 0
	return ret_array
		
