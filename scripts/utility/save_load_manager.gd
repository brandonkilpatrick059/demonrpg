class_name SaveLoadManager extends Node

var save_file : FileAccess

static var  extension : String = ".witch"
static var saves_location : String = "user://save_games"

var loading_file_path : String = ""

func _ready() -> void:
	var dir : DirAccess = DirAccess.open("user://")
	if(!dir.dir_exists(saves_location)):
		dir.make_dir(saves_location)

func settings_save_file_exists() -> bool:
	return FileAccess.file_exists("user://settings.save")

#func load_file(file_path : String):
	#var temp_vol = AudioServer.get_bus_volume_db(0)
	#var zero_volume : float = -60
	#AudioServer.set_bus_volume_db(0,zero_volume)
	#var grid_base : Grid_Base = get_tree().get_first_node_in_group("grid_base")
	#grid_base.clear_grid()
	#save_file = FileAccess.open(file_path, FileAccess.READ)
	#while(save_file.get_position() < save_file.get_length()):
		#var line = save_file.get_line()
		#var dictionary : Dictionary = JSON.parse_string(line)
		#var type = String(dictionary.get("type"))
		#match type:
			#"grid_entity":
				#load_grid_entity(dictionary)
			#"tree":
				#load_tree(dictionary)
	#save_file.close()
	#grid_base.update()
	#AudioServer.set_bus_volume_db(0,temp_vol)

func save(file_name : String): 
	var path = str(str(saves_location,file_name),extension)
	save_file= FileAccess.open(path, FileAccess.WRITE)
	save_game()
	save_file.close()

func save_game():
	save_location()
	save_total_time()
	save_player()
	save_game_state()
	save_familiars()

func save_location():
	var loc_name : String = "" #TODO: retrieve
	save_file.store_line(loc_name)

func save_total_time():
	var time_secs : float = 0.0 #TODO: retrieve
	save_file.store_line(str(time_secs))

func save_game_state():
	var state : GlobalGamestate = get_tree().get_first_node_in_group("gamestate")
	var save_dict = state.get_save_dictionary()
	save_file.store_line(JSON.stringify(save_dict))

func save_familiars():
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	var familiars : Array[Familiar] = player_ref.get_familiars_team()
	for familiar in familiars:
		var save_dict = familiar.get_save_dictionary()
		save_file.store_line(save_dict)

func save_player():
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	var save_dict : Dictionary = player_ref.get_save_dictionary()
	save_file.store_line(JSON.stringify(save_dict))

#func get_grid_entity_dictionary(entity : Grid_Entity) -> Dictionary:
	#var grid_entity_dictionary : Dictionary = {
		#"type" : "grid_entity",
		#"pos_x" : entity.global_position.x,
		#"pos_y" : entity.global_position.y,
		#"packedscene_path" : entity.get_packedscene_path()
	#}
	#return grid_entity_dictionary
