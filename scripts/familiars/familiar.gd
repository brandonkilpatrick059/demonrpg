class_name Familiar extends Node2D

#STATS
var stats : Array[String] =[
	"max health",
	"attack",
	"defense",
	"speed",
	"magic",
	"num_actions"
]

@export var packedscene_path : String = ""
@export var familiar_name : String = ""
@export var max_hp : int = 1
@export var current_hp : int = 1
@export var attack : int = 1
@export var defense : int = 1
@export var speed : int = 1
@export var magic : int = 1
@export var num_actions : int = 1
var actions_taken = 0
@export var no_sigil : bool = false
@export var incorporeal : bool = false

@export var evolutions : Array[Evolution] = []

var max_energy = 4
var current_energy = 0
var energy_depleted : bool = false

@export var level : int = 1
@export var experience : int = 0

var capture_offered : bool = false

var active : bool = false
var sigil : String = ""

var stored : bool = false

#var exp_req_for_level_up : Array[int] = [
	#10, #Level 0 -> Level 1
	#20, #Level 1 -> Level 2
	#30, #Level 2 -> level 3
	#40, #Level 3 -> Level 4
#]

var exp_req_for_level_up : Array[int] = [
	30, #Level 0 -> Level 1
	500, #Level 1 -> Level 2
	5000, #Level 2 -> level 3
	15000, #Level 3 -> Level 4
]

var actions : Array[BattleAction] = []

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

@onready var actions_parent : Node = $actions
@export var action_cadence_0 : Array[String]
@export var action_cadence_1 : Array[String]
@export var action_cadence_2 : Array[String]
var current_action_cadence : int = 0
var action_cadence_index : int = 0

var hostile : bool = false
var dead : bool = false

@export var battle_buffs : Array[BattleBuff] = []

var one_shot_animating : bool = false

var stat_increase_value : int = 0
var stat_increase : String = ""

func _ready() -> void:
	for action_node in actions_parent.get_children():
		actions.append(action_node)
	sprite.play("default")
	sprite.frame = randi_range(0,sprite.sprite_frames.get_frame_count("default")-1)
	if(sigil == "" && not no_sigil):
		sigil = Sigil.get_unused_sigil()
	use_parent_material = true
	$AnimatedSprite2D.use_parent_material = true
	
	if($evolutions != null):
		for child in $evolutions.get_children():
			evolutions.append(child)

func set_stored():
	stored = true
	
func set_roused():
	stored = false

func is_stored():
	return stored

func is_ready_to_evolve() -> bool:
	if(experience >= exp_req_for_level_up[level] && 
	evolutions.size() > 0 &&
	not is_dead()):
		return true
	else:
		return false

func get_evolutions() -> Array[Evolution]:
	return evolutions

func gen_stat_increase():
	#max health is twice as likely as all others
	if(randf_range(0.0,1.0) < 0.5):
		stat_increase = stats[0]
	else:
		var random_index = randi_range(0,stats.size()-2)
		stat_increase = stats[random_index]
	stat_increase_value = randi_range(1,3)

func get_exp_value() -> int:
	var total = max_hp
	total = total + attack
	total = total + defense
	total = total + speed
	total = total + magic
	total = total + experience
	return total

func get_actions_taken() -> int:
	return actions_taken

func action_taken():
	actions_taken = actions_taken + 1

func reset_actions_taken():
	actions_taken = 0

func get_next_action() -> BattleAction:
	var current_cadence : Array[String] = get_action_cadence(current_action_cadence)
	var ret_action : BattleAction
	if(action_cadence_0.size() == 0 && 
	action_cadence_1.size() == 0 && 
	action_cadence_2.size() == 0):
		return ret_action
	elif(action_cadence_index < current_cadence.size()):
		var action_name = current_cadence[action_cadence_index]
		ret_action = get_action_by_name(action_name)
		action_cadence_index = action_cadence_index + 1
	else:
		action_cadence_index = 0
		randomize_action_cadence()
		current_cadence = get_action_cadence(current_action_cadence)
		var action_name = current_cadence[action_cadence_index]
		ret_action = get_action_by_name(action_name)
		action_cadence_index = action_cadence_index + 1
	return ret_action

func get_capture_range() -> int:
	if(max_hp <= 5):
		return 3
	elif(max_hp <= 10):
		return 5
	elif(max_hp <= 20):
		return 8
	elif(max_hp <= 30):
		return 12
	else:
		return 10

func randomize_action_cadence():
	var num_cadences = 0
	#always at least one cadence
	if(action_cadence_1.size() > 0):
		num_cadences = num_cadences + 1
	if(action_cadence_2.size() > 0):
		num_cadences = num_cadences + 1
	action_cadence_index = randi_range(0,num_cadences)

func get_action_by_name(name : String) -> BattleAction:
	for action : BattleAction in actions:
		if(action.get_action_name() == name):
			return action
	return null

func get_action_cadence(index : int) -> Array[String]:
	match index:
		0:
			return action_cadence_0
		1:
			return action_cadence_1
		2:
			return action_cadence_2
		_:
			return action_cadence_0

func is_capture_offered() -> bool:
	return capture_offered

func set_capture_offered():
	capture_offered = true

func get_stat_increase() -> String:
	return stat_increase

func get_stat_increase_value() -> int:
	return stat_increase_value

func consume_familiar(familiar : Familiar, exp_multiplier : float = 1.0):
	var increase_stat : String = familiar.get_stat_increase()
	var value : int = familiar.get_stat_increase_value()
	match(increase_stat):
		"max health":
			max_hp = max_hp + value
		"attack":
			attack = attack + value
		"defense":
			defense = defense + value
		"speed":
			speed = speed + value
		"magic":
			magic = magic + value
		"num_actions":
			num_actions = num_actions + value
	experience = experience + (familiar.get_exp_value() * exp_multiplier)

func get_sigil() -> String:
	return sigil

func set_sigil(in_sigil : String):
	sigil = in_sigil

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
	var buff_y = -32
	if(not is_hostile()):
		buff_y = 32
	match battle_buffs.size():
		1:
			battle_buffs[0].global_position = global_position + Vector2(0,buff_y)
		2:
			battle_buffs[0].global_position = global_position + Vector2(-8,buff_y)
			battle_buffs[1].global_position = global_position + Vector2(8,buff_y)
		3:
			battle_buffs[0].global_position = global_position + Vector2(-12,buff_y)
			battle_buffs[1].global_position = global_position + Vector2(0,buff_y)
			battle_buffs[2].global_position = global_position + Vector2(12,buff_y)
		4:
			battle_buffs[0].global_position = global_position + Vector2(-16,buff_y)
			battle_buffs[1].global_position = global_position + Vector2(-8,buff_y)
			battle_buffs[2].global_position = global_position + Vector2(8,buff_y)
			battle_buffs[3].global_position = global_position + Vector2(16,buff_y)
	

func get_max_energy() -> int:
	return max_energy

func get_current_energy() -> int:
	return current_energy

func energy_is_depleted() -> bool:
	return energy_depleted

func set_current_energy(num : int):
	current_energy = num
	if (num == 0):
		energy_depleted = true

func use_energy(num : int):
	current_energy = current_energy - num
	energy_depleted = true

func reset_energy():
	energy_depleted = false

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

func kill(return_sigil : bool = true):
	play_one_shot_animation("die")
	gen_stat_increase()
	clear_buffs()
	if(return_sigil):
		Sigil.return_sigil(sigil)
	dead = true

func get_exp() -> int:
	return experience

func get_exp_to_next() -> String:
	if(get_evolutions().size() > 0):
		return str(exp_req_for_level_up[level])
	else:
		return "N/A"

func clear_buffs():
	for buff in battle_buffs:
		if(buff != null):
			buff.queue_free()
	battle_buffs.clear()

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

func get_familiar_name(exclude_sigil : bool = false) -> String:
	var ret_name = familiar_name
	if(not no_sigil && not exclude_sigil):
		var img_bbcode = "[img]{path}[/img]"
		img_bbcode = img_bbcode.replace("{path}",sigil)
		ret_name = str(ret_name,img_bbcode)
	return ret_name

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

func is_incorporeal() -> bool:
	return incorporeal

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
	run_status_effects()
	clean_buffs_list()
	arrange_buffs()

func heal_status_effects():
	var new_buffs : Array[BattleBuff] = []
	for buff : BattleBuff in battle_buffs:
		if(not buff.is_status_effect() or 
		(buff.is_status_effect() and not buff.is_cured_by_heal())):
			new_buffs.append(buff)
		else:
			buff.queue_free()
	battle_buffs.clear()
	battle_buffs.append_array(new_buffs)
	arrange_buffs()

func run_status_effects():
	for buff : BattleBuff in battle_buffs:
		if(buff != null &&
		buff.is_status_effect()):
			buff.apply_status_effect()

func play_one_shot_animation(name : String):
	sprite.play(name)
	one_shot_animating = true

func get_num_actions() -> int:
	return num_actions

func set_num_actions(num : int):
	num_actions = num

func set_active():
	active = true
	visible = true

func set_inactive():
	active = false
	visible = false

func get_save_dictionary() -> Dictionary:
	var ret_dictionary : Dictionary = {
		"packedscene" : packedscene_path,
		"name" : familiar_name,
		"sigil" : sigil,
		"max_hp" : max_hp,
		"current_hp" : current_hp,
		"attack" : attack,
		"defense" : defense,
		"speed" : speed,
		"magic" : magic,
		"num_actions" : num_actions,	
		"level" : level,
		"experience" : experience,
		"stored" : stored
	}
	return ret_dictionary

func load_from_dictionary(dictionary : Dictionary):
	familiar_name = dictionary.get("name")
	sigil = dictionary.get("sigil")
	Sigil.checkout_sigil(sigil)
	max_hp = int(dictionary.get("max_hp"))
	current_hp = int(dictionary.get("current_hp"))
	attack = int(dictionary.get("attack"))
	defense = int(dictionary.get("defense"))
	speed = int(dictionary.get("speed"))
	num_actions = int(dictionary.get("num_actions"))
	magic = int(dictionary.get("magic"))
	level = int(dictionary.get("level"))
	experience = int(dictionary.get("experience"))
	stored = bool(dictionary.get("stored"))

func _physics_process(delta: float) -> void:
	if(active):
		if(one_shot_animating &&
		sprite.frame == sprite.sprite_frames.get_frame_count(sprite.animation)-1):
			if(is_dead()):
				sprite.play("dead")
				if(incorporeal):
					queue_free()
			else:
				sprite.play("default")
			one_shot_animating = false
