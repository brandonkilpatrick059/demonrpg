extends Node

@export var texts : Array[Text] = []

func run_script():
	var player : Player = get_tree().get_first_node_in_group("player")
	player.play_texts(texts)
