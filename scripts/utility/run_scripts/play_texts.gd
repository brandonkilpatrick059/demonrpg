extends Node

@export var texts : Array[Text] = []
@export var dark_texts : Array[bool] = []

func run_script():
	var player : Player = get_tree().get_first_node_in_group("player")
	if(dark_texts.size() == 0):
		player.play_texts(texts)
	else:
		player.play_texts(texts,dark_texts)
