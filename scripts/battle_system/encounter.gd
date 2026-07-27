class_name Encounter extends Node

@export var opponents : Array[Familiar]
@export var music : AudioStream
@export var background : Texture

func get_opponents() -> Array[Familiar]:
	return opponents

func get_music() -> AudioStream:
	return music

func get_background() -> Texture:
	return background
