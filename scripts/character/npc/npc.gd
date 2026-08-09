class_name Monster extends StaticBody2D

@export var wander_wait_min : float = 2.0
@export var wander_wait_max : float = 8.0

var facing_direction : String = "right"

var moving : bool = false
var talking : bool = false

var grid_velocity : Vector2 = Vector2(0,0)
var move_speed : float = 1.0

var up_colliding_bodies : Array[Node] = []
var down_colliding_bodies : Array[Node] = []
var left_colliding_bodies : Array[Node] = []
var right_colliding_bodies : Array[Node] = []


@onready var colliders : Array[Area2D] = [
	$move_collider_left,
	$move_collider_down,
	$move_collider_right,
	$move_collider_up]

func _ready() -> void:
	deactivate_walk_colliders()
	add_to_group("npc")
	$Timer.start(randf_range(wander_wait_min,wander_wait_max))

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

func end_awaiting_input():
	talking = false
	var player : Player = get_tree().get_first_node_in_group("player")
	player.unfreeze_input()
	player.start_input_timer(0.5)
	$Timer.start(randf_range(wander_wait_min,wander_wait_max))

func handle_movement():
	global_position = global_position + grid_velocity
	if(talking):
		stop()
	elif($Timer.is_stopped()):
		if(not moving):
			if(get_free_facing_direction()):
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

func interact(player_dir : String):
	if(grid_aligned() and not talking and $dialog != null):
		stop()
		talking = true
		var texts : Array[String] = $dialog.get_current_text()
		$InterfaceMessageSpeech.queue_text(texts)
		var camera : Camera2D = get_tree().get_first_node_in_group("camera")
		var pos : Vector2 = camera.get_screen_center_position()
		$InterfaceMessageSpeech.global_position = pos + Vector2(-64,80)
		var player : Player = get_tree().get_first_node_in_group("player")
		player.freeze_input()
		match player_dir:
			"up":
				facing_direction = "down"
			"down":
				facing_direction = "up"
			"left":
				facing_direction = "right"
			"right":
				facing_direction = "left"

func get_free_facing_direction() -> bool:
	var free_colliders : Array[Area2D] = []
	if(up_colliding_bodies.size() == 0):
		free_colliders.append(($move_collider_up))
	if(down_colliding_bodies.size() == 0):
		free_colliders.append(($move_collider_down))
	if(left_colliding_bodies.size() == 0):
		free_colliders.append(($move_collider_left))
	if(right_colliding_bodies.size() == 0):
		free_colliders.append(($move_collider_right))
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
		return true
	else:
		stop()
		return false

func colliders_detect_solid() -> bool:
	match facing_direction:
		"up":
			if(up_colliding_bodies.size() > 0):
				return true
		"down":
			if(down_colliding_bodies.size() > 0):
				return true
		"left":
			if(left_colliding_bodies.size() > 0):
				return true
		"right":
			if(right_colliding_bodies.size() > 0):
				return true
	return false

func _physics_process(delta: float) -> void:
	handle_animation()
	handle_movement()


func _on_move_collider_left_body_entered(body: Node2D) -> void:
	if(body!= self):
		left_colliding_bodies.append(body)


func _on_move_collider_left_body_exited(body: Node2D) -> void:
	if(body!= self):
		left_colliding_bodies.erase(body)


func _on_move_collider_up_body_entered(body: Node2D) -> void:
	if(body!= self):
		up_colliding_bodies.append(body)


func _on_move_collider_up_body_exited(body: Node2D) -> void:
	if(body!= self):
		up_colliding_bodies.erase(body)


func _on_move_collider_down_body_entered(body: Node2D) -> void:
	if(body!= self):
		down_colliding_bodies.append(body)


func _on_move_collider_down_body_exited(body: Node2D) -> void:
	if(body!= self):
		down_colliding_bodies.erase(body)


func _on_move_collider_right_body_entered(body: Node2D) -> void:
	if(body!= self):
		right_colliding_bodies.append(body)


func _on_move_collider_right_body_exited(body: Node2D) -> void:
	if(body!= self):
		right_colliding_bodies.erase(body)
