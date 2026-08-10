extends Node

@export var texts : Array[Text] = []
@export var interact_node : Node

func run_script():
	var player : Player = get_tree().get_first_node_in_group("player")
	var text_strings : Array[String] = []
	for text in texts:
		text_strings.append(text.get_text("english"))
	interact_node.set_queued_texts(text_strings)
	player.interact_with(interact_node)
