class_name Monster extends StaticBody2D

@export var wander_wait_min : float = 2.0
@export var wander_wait_max : float = 8.0

var facing_direction : String = "right"

var moving : bool = false

var grid_velocity : Vector2 = Vector2(0,0)
var move_speed : float = 1.0


@onready var colliders : Array[Area2D] = [
	$move_collider_left,
	$move_collider_down,
	$move_collider_right,
	$move_collider_up]

func _ready() -> void:
	deactivate_walk_colliders()

func deactivate_walk_colliders():
	$walk_shape_down.disabled = true
	$walk_shape_up.disabled = true
	$walk_shape_left.disabled = true
	$walk_shape_right.disabled = true

func activate_walk_collider(direction : String):
	match direction:
		"up":
			$walk_shape_up.disabled = false
		"down":
			$walk_shape_down.disabled = false
		"left":
			$walk_shape_left.disabled = false
		"right":
			$walk_shape_right.disabled = false

func handle_animation():
	if(moving):
		var name : String = str("walk_",facing_direction)
		if($AnimatedSprite2D.animation != name):
			$AnimatedSprite2D.play(name)
	else:
		var name : String = str("stand_",facing_direction)
		if($AnimatedSprite2D.animation != name):
			$AnimatedSprite2D.play(name)

func handle_movement():
	global_position = global_position + grid_velocity
	if($Timer.is_stopped()):
		if(not moving):
			get_free_facing_direction()
			moving = true
			match facing_direction:
				"up":
					grid_velocity = Vector2(0,-move_speed)
				"down":
					grid_velocity = Vector2(0,move_speed)
				"left":
					grid_velocity = Vector2(-move_speed,0)
				"right":
					grid_velocity = Vector2(move_speed,0)
			activate_walk_collider(facing_direction)
			$Timer.start(randf_range(wander_wait_min,wander_wait_max))
		elif(grid_aligned()):
			stop()
	elif(grid_aligned() and colliders_detect_solid()):
		stop()

func stop():
	grid_velocity = Vector2(0,0)
	moving = false
	deactivate_walk_colliders()

func grid_aligned() -> bool:
	return fmod(global_position.x,24) == 0 && fmod(global_position.y,24) == 0

func get_free_facing_direction():
	var free_colliders : Array[Area2D] = []
	for collider in colliders:
		if(collider.get_overlapping_bodies().size() == 0):
			free_colliders.append(collider)
	if(free_colliders.size() > 0):
		var collider = free_colliders[randi_range(0,free_colliders.size()-1)]
		if(collider == $move_collider_down):
			facing_direction = "down"
		elif(collider == $move_collider_up):
			facing_direction = "up"
		elif(collider == $move_collider_right):
			facing_direction = "right"
		elif(collider == $move_collider_left):
			facing_direction = "left"
	else:
		moving = false
		grid_velocity = Vector2(0,0)

func colliders_detect_solid() -> bool:
	match facing_direction:
		"up":
			if($move_collider_up.get_overlapping_bodies().size() > 0):
				return true
		"down":
			if($move_collider_down.get_overlapping_bodies().size() > 0):
				return true
		"left":
			if($move_collider_left.get_overlapping_bodies().size() > 0):
				return true
		"right":
			if($move_collider_right.get_overlapping_bodies().size() > 0):
				return true
	return false

func _physics_process(delta: float) -> void:
	handle_animation()
	handle_movement()
