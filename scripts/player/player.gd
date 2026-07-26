class_name Player extends Node2D

var familiar_team : Array[Familiar] = []
var stored_familiars : Array[Familiar] = []
@export var pentacle_charms : int = 0

var facing_direction : String = "down"
var walking : bool = false
var moving : bool = false

@onready var body : AnimatedSprite2D = $body
@onready var head : AnimatedSprite2D = $head
@onready var flash_light : PointLight2D = $PointLight2D
@onready var move_collider : Area2D = $move_collider

var move_speed_vect : Vector2 = Vector2(0,0)

@export var active : bool = false

func _ready() -> void:
	head.play(facing_direction)

func get_familiars_team() -> Array[Familiar]:
	return familiar_team

func set_familiars_team(in_team : Array[Familiar]):
	familiar_team.clear()
	familiar_team.append_array(in_team)

func get_stored_familiars() -> Array[Familiar]:
	return stored_familiars

func set_stored_familiars(in_familiars : Array[Familiar]):
	stored_familiars.clear()
	stored_familiars.append_array(in_familiars)

func get_pentacle_charms() -> int:
	return pentacle_charms

func set_pentacle_charms(num : int):
	pentacle_charms = num

func handle_input():
	if(Input.is_action_pressed("up")):
		if(grid_aligned()):
			walking = true
			facing_direction = "up"
	elif(Input.is_action_pressed("down")):
		if(grid_aligned()):
			walking = true
			facing_direction = "down"
	elif(Input.is_action_pressed("left")):
		if(grid_aligned()):
			walking = true
			facing_direction = "left"
	elif(Input.is_action_pressed("right")):
		if(grid_aligned()):
			walking = true
			facing_direction = "right"
	else:
		walking = false

func handle_animation():
	if(moving):
		var animation_name : String =str("walk_",facing_direction)
		if(body.animation != animation_name):
			body.play(animation_name)
	else:
		var animation_name : String =str("stand_",facing_direction)
		if(body.animation != animation_name):
			body.play(animation_name)
	if(head.animation != facing_direction):
		var keep_frame : int = head.frame
		var keep_progress : float = head.frame_progress 
		head.play(facing_direction)
		head.frame = keep_frame
		head.frame_progress = keep_progress

func handle_movement():
	if(walking):
		var speed : int = 1
		if(grid_aligned()):
			match facing_direction:
				"up":
					if($move_collider_up.get_overlapping_bodies().size() == 0):
						move_speed_vect = Vector2(0,-speed)
						moving = true
					else:
						move_speed_vect = Vector2(0,0)
				"down":
					if($move_collider_down.get_overlapping_bodies().size() == 0):
						move_speed_vect = Vector2(0,speed)
						moving = true
					else:
						move_speed_vect = Vector2(0,0)
				"left":
					if($move_collider_left.get_overlapping_bodies().size() == 0):
						move_speed_vect = Vector2(-speed,0)
						moving = true
					else:
						move_speed_vect = Vector2(0,0)
				"right":
					if($move_collider_right.get_overlapping_bodies().size() == 0):
						move_speed_vect = Vector2(speed,0)
						moving = true
					else:
						move_speed_vect = Vector2(0,0)
	else:
		if(grid_aligned()):
			move_speed_vect = Vector2(0,0)
			moving = false
	global_position = global_position + move_speed_vect

func grid_aligned() -> bool:
	return fmod(global_position.x,24) == 0 && fmod(global_position.y,24) == 0

func set_active():
	active = true

func set_inactive():
	active = false

func _physics_process(delta: float) -> void:
	if(active):
		handle_input()
		handle_animation()
		handle_movement()
	
