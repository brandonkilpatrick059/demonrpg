class_name LocationZone extends Node2D

@export var zone_name : String = ""
@export var zone_links : Array[ZoneLink] = []

var switching_zones : bool = false

func get_link_by_name(link_name : String) -> ZoneLink:
	for link : ZoneLink in zone_links:
		if link.get_link_name() == link_name:
			return link
	return null
