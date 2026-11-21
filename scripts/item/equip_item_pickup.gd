extends StaticBody2D
@export var gamestate_name : String = ""
@export var item : EquipItem = null

func _ready() -> void:
	var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	if(gamestate.get_state_map_value(gamestate_name) == "GATHERED"):
		queue_free()

func interact():
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	if(player_ref.get_stored_equip_items().size() < player_ref.get_max_stored_equip_items()):
		var name_text : Text = item.get_name_text()
		var description_text : Text = item.get_description_text()
		player_ref.play_texts([$Text,name_text,$Text_take])
		player_ref.add_stored_equip_item(item)
		item.reparent(player_ref)
		var gamestate : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
		gamestate.set_state_map_value(gamestate_name,"GATHERED")
		player_ref.play_sound(load("res://audio/effects/equip.ogg"))
		queue_free()
	if(player_ref.get_stored_equip_items().size() >= player_ref.get_max_stored_equip_items()):
		var name_text : Text = item.get_name_text()
		var description_text : Text = item.get_description_text()
		player_ref.play_texts([$Text,name_text,$Text_leave])
