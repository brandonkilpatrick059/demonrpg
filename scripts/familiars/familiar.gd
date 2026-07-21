class_name Familiar extends Node2D

#STATS
@export var familiar_name : String = ""
@export var max_hp : int = 1
@export var current_hp : int = 1
@export var attack : int = 1
@export var defense : int = 1
@export var speed : int = 1
@export var magic : int = 1
@export var num_actions : int = 1

var max_energy = 4
var current_energy = 4

@export var level : int = 1
@export var experience : int = 0

var actions : Array[BattleAction] = []


@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

@onready var actions_parent : Node = $actions

var hostile : bool = false
var dead : bool = false

@export var battle_buffs : Array[BattleBuff] = []

var one_shot_animating : bool = false

func _ready() -> void:
	for action_node in actions_parent.get_children():
		actions.append(action_node)
	sprite.play("default")
	sprite.frame = randi_range(0,sprite.sprite_frames.get_frame_count("default")-1)

func get_max_hp() -> int:
	return max_hp

func is_hostile():
	return hostile

func add_battle_buff(new_buff : BattleBuff):
	if(not is_dead()):
		clean_buffs_list()
		var stacked : bool = false
		for buff in battle_buffs:
			if buff != null:
				if buff.get_type() == new_buff.get_type():
					buff.stack(new_buff)
					stacked = true
					new_buff.queue_free()
		if(not stacked && battle_buffs.size() < 4):
			var battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
			battle_sys_ref.add_child(new_buff)
			battle_buffs.append(new_buff)
			arrange_buffs()

func arrange_buffs():
	clean_buffs_list()
	match battle_buffs.size():
		1:
			battle_buffs[0].global_position = global_position
		2:
			battle_buffs[0].global_position = global_position + Vector2(-8,0)
			battle_buffs[1].global_position = global_position + Vector2(8,0)
		3:
			battle_buffs[0].global_position = global_position + Vector2(-12,0)
			battle_buffs[1].global_position = global_position + Vector2(0,0)
			battle_buffs[2].global_position = global_position + Vector2(12,0)
		4:
			battle_buffs[0].global_position = global_position + Vector2(-16,0)
			battle_buffs[1].global_position = global_position + Vector2(-8,0)
			battle_buffs[2].global_position = global_position + Vector2(8,0)
			battle_buffs[3].global_position = global_position + Vector2(16,0)
	

func get_max_energy() -> int:
	return max_energy

func get_current_energy() -> int:
	return current_energy

func set_current_energy(num : int):
	current_energy = num

func get_battle_buffs() -> Array[BattleBuff]:
	return battle_buffs

func mark_hostile():
	hostile = true

func mark_friendly():
	hostile = false

func set_max_hp(num : int):
	max_hp = num

func get_current_hp() -> int:
	return current_hp

func set_current_hp(num : int):
	current_hp = num

func is_dead():
	return dead

func kill():
	play_one_shot_animation("die")
	dead = true

func get_attack() -> int:
	return attack

func set_attack(num : int):
	attack = num

func get_defense() -> int:
	return defense

func set_defense(num : int):
	defense = num

func set_familiar_name (in_name : String):
	familiar_name = in_name

func get_familiar_name() -> String:
	return familiar_name

func get_speed() -> int:
	return speed

func set_speed(num : int):
	speed = num

func get_magic() -> int:
	return magic

func set_magic(num : int):
	magic = num

func get_actions():
	return actions

func clean_buffs_list():
	var new_buffs_list : Array[BattleBuff] = []
	for buff in battle_buffs:
		if(buff != null):
			new_buffs_list.append(buff)
	battle_buffs.clear()
	battle_buffs.append_array(new_buffs_list)

func update_buffs():
	for buff : BattleBuff in battle_buffs:
		if(buff != null):
			buff.add_round_active()
	clean_buffs_list()
	arrange_buffs()

func play_one_shot_animation(name : String):
	sprite.play(name)
	one_shot_animating = true

func _physics_process(delta: float) -> void:
	if(one_shot_animating &&
	sprite.frame == sprite.sprite_frames.get_frame_count(sprite.animation)-1):
		if(is_dead()):
			sprite.play("dead")
		else:
			sprite.play("default")
		one_shot_animating = false
