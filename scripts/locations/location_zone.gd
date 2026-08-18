class_name LocationZone extends Node2D

@export var zone_name : String = ""
@export var zone_links : Array[ZoneLink] = []
@export var dark : bool = false
@export var dark_canvas_mod : CanvasModulate

var switching_zones : bool = false

func get_link_by_name(link_name : String) -> ZoneLink:
	for link : ZoneLink in zone_links:
		if link.get_link_name() == link_name:
			return link
	return null

func set_is_dark():
	dark = true
	dark_canvas_mod.visible = true

func set_is_not_dark():
	dark = false
	#dark_canvas_mod.visible = false

func is_dark() -> bool:
	return dark
