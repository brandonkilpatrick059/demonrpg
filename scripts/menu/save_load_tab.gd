class_name  SaveLoadTab extends Node2D

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var location : Label = $location
@onready var play_time : Label = $play_time
@onready var empty : Label = $empty
@onready var familiars: RichTextLabel = $familiars_label
@onready var num_charms : Label = $num_charms

func set_active():
	sprite.play("active")

func set_inactive():
	sprite.play("inactive")

func set_tab(loc : String, time : String, list_familiars : String, num_seals : int):
	location.text = loc
	location.visible = true
	play_time.text = time
	play_time.visible = true
	familiars.parse_bbcode(list_familiars)
	familiars.visible = true
	num_charms.visible = true
	$pentacle_charm.visible = true
	num_charms.text = str("x",num_seals)
	empty.visible = false

func set_empty():
	location.visible = false
	play_time.visible = false
	familiars.visible = false
	empty.visible = true
	$pentacle_charm.visible = false
	num_charms.visible = false
