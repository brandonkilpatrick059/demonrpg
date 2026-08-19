class_name  SaveLoadTab extends Node2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var location : Label = $location
@onready var play_time : Label = $play_time
@onready var empty : Label = $empty
@onready var familiars: RichTextLabel = $familiars_label

func set_active():
	sprite.play("active")

func set_inactive():
	sprite.play("inactive")

func set_tab(loc : String, time : String, list_familiars : String):
	location.text = loc
	play_time.text = time
	familiars.parse_bbcode(list_familiars)
	empty.visible = false
