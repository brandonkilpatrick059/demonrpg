class_name Monster extends Area2D

@export var encounter : PackedScene
@export var wander_wait_min : float = 2.0
@export var wander_wait_max : float = 8.0

var facing_direction : String = "right"

var moving : bool = false
var charging : bool = false

var grid_velocity : Vector2 = Vector2(0,0)
var move_speed : float = 1.0
var charge_speed : float = 2.0


@onready var colliders : Array[Area2D] = [
	$move_collider_left,
	$move_collider_down,
	$move_collider_right,
	$move_collider_up]

func handle_animation():
	$AnimatedSprite2D.play(facing_direction)

func check_charge_player():
	var player : Player = get_tree().get_first_node_in_group("player")
	if(player.is_active()):
		if (global_position.distance_to(player.global_position) < 264):
			if(grid_aligned() && 
			global_position.x == player.global_position.x):
				if(player.global_position.y > global_position.y):
					if(facing_direction == "down" 
					&& not colliders_detect_solid()):
						grid_velocity = Vector2(0,charge_speed)
						charging = true
						moving = false
						make_noise()
				else:
					if(facing_direction == "up"
					&& not colliders_detect_solid()):
						grid_velocity = Vector2(0,-charge_speed)
						charging = true
						moving = false
						make_noise()
			elif(grid_aligned() &&
			global_position.y == player.global_position.y):
				if(player.global_position.x > global_position.x):
					if(facing_direction == "right"
					&& not colliders_detect_solid()):
						grid_velocity = Vector2(charge_speed,0)
						charging = true
						moving = false
						make_noise()
				else:
					if(facing_direction == "left"
					&& not colliders_detect_solid()):
						grid_velocity = Vector2(-charge_speed,0)
						charging = true
						moving = false
						make_noise()

func make_noise():
	var noise : int = randi_range(1,3)
	var path = str(str("res://audio/effects/monster_noise_",noise),".ogg")
	$AudioStreamPlayer2D.stream = load(path)
	$AudioStreamPlayer2D.play()

func handle_movement():
	global_position = global_position + grid_velocity
	if(charging):
		if(grid_aligned() and colliders_detect_solid()):
			charging = false
			grid_velocity = Vector2(0,0)
			global_position = global_position.snapped(Vector2(24,24))
	elif($Timer.is_stopped() and not charging and not moving):
		get_free_facing_direction()
		moving = true
		charging = false
		match facing_direction:
			"up":
				grid_velocity = Vector2(0,-move_speed)
			"down":
				grid_velocity = Vector2(0,move_speed)
			"left":
				grid_velocity = Vector2(-move_speed,0)
			"right":
				grid_velocity = Vector2(move_speed,0)
		global_position = global_position + grid_velocity
		$Timer.start(randf_range(3.0,8.0))
	if(grid_aligned()):
		if(not charging):
			if(moving):
				grid_velocity = Vector2(0,0)
				moving = false
			check_charge_player()

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


func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("player")):
		var player : Player = body
		if(player.is_active()):
			var new_encounter : Encounter = encounter.instantiate()
			player.start_encounter(new_encounter)
			queue_free()
