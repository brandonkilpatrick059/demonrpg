class_name ZoneLink extends Area2D

@export var link_zone_scene_path : String
@export var link_name : String = ""
@export var teleport_spot : Node2D
@export var stop_point : Node2D
@export var to_link_name : String = ""

func get_link_name() -> String:
	return link_name

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("player")):
		var player_ref : Player = body
		if(not player_ref.input_is_frozen()):
			var zone_manager : ZoneManager = get_tree().get_first_node_in_group("zone_manager")
			zone_manager.switch_zones(load(link_zone_scene_path),to_link_name)

func get_teleport_position() -> Vector2:
	return teleport_spot.global_position

func get_stop_point() -> Vector2:
	return stop_point.global_position
