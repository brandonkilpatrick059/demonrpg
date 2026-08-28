class_name Encounter extends Node

@export var opponents : Array[Familiar]
@export var music : AudioStream
@export var background : Texture
@export var can_escape : bool = true

func get_opponents() -> Array[Familiar]:
	return opponents

func get_music() -> AudioStream:
	return music

func add_opponent(opponent : Familiar):
	opponents.append(opponent)

func get_background() -> Texture:
	return background

func is_escapable() -> bool:
	return can_escape
