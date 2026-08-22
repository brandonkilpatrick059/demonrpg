class_name SaveLoadManager extends Node

var save_file : FileAccess

static var  extension : String = ".witch"
static var saves_location : String = "user://save_games"

var loading_file_path : String = ""

var num_save_slots : int = 4

func _ready() -> void:
	var dir : DirAccess = DirAccess.open("user://")
	if(!dir.dir_exists(saves_location)):
		dir.make_dir(saves_location)

func settings_save_file_exists() -> bool:
	return FileAccess.file_exists("user://settings.save")

func game_save_file_exists(name : String) -> bool:
	return FileAccess.file_exists(name)

func get_load_tab(save_slot : int, tab : SaveLoadTab):
	var file_path = str(str(saves_location,str("/save_",save_slot)),extension)
	if(game_save_file_exists(file_path)):
		save_file = FileAccess.open(file_path, FileAccess.READ)
		var location_line : String = save_file.get_line()
		save_file.get_line() #scenepath
		save_file.get_line() #time played
		save_file.get_line() #game state 
		var player_line = save_file.get_line()
		var player_dictionary : Dictionary = JSON.parse_string(player_line)
		var num_charms : int = int(player_dictionary.get("pentacle_charms"))
		var name_line : String = ""
		while(save_file.get_position() < save_file.get_length()):
			var line = save_file.get_line()
			var dictionary : Dictionary = JSON.parse_string(line)
			var stored : bool = bool(dictionary.get("stored"))
			if(not stored):
				var fam_name : String = dictionary.get("name")
				var sigil : String = dictionary.get("sigil")
				sigil = str("[img]",sigil)
				sigil = str(sigil,"[/img]")
				fam_name = str(fam_name,sigil)
				name_line = str(name_line,str(fam_name," | "))
		tab.set_tab(location_line,"",name_line,num_charms)
		save_file.close()
	else:
		tab.set_empty()

func save(slot : int, location : String, load_scene_path : String): 
	var path = str(str(saves_location,str("/save_",slot)),extension)
	save_file= FileAccess.open(path, FileAccess.WRITE)
	save_game(location,load_scene_path)
	save_file.close()

func save_game(location : String, load_scene_path : String):
	save_location(location,load_scene_path)
	save_total_time() #TODO: implement
	save_game_state()
	save_player()
	save_familiars()

func save_location(location: String, load_scene_path : String):
	save_file.store_line(location)
	save_file.store_line(load_scene_path)

func save_total_time():
	pass
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
		save_file.store_line(JSON.stringify(save_dict))
	for familiar in player_ref.get_stored_familiars():
		var save_dict = familiar.get_save_dictionary()
		save_file.store_line(JSON.stringify(save_dict)) 

func save_player():
	var player_ref : Player = get_tree().get_first_node_in_group("player")
	var save_dict : Dictionary = player_ref.get_save_dictionary()
	save_file.store_line(JSON.stringify(save_dict))
