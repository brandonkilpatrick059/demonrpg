class_name PostBattleBuff extends TypeItemBuff

#add percentage to received physical damage
#POSITIVE = take MORE DAMAGE
#NEGATIVE = damage REDUCED
@export var phys_dmg_scale_add : float = 0.0

#add percentage to received magic damage
#POSITIVE = take MORE DAMAGE
#NEGATIVE = damage REDUCED
@export var magic_dmg_scale_add : float = 0.0

#add percentage phys damage to type
@export var add_dealt_phys_dmg_to_type : String = "type name"
@export var type_dealt_phys_dmg_scale_add : float = 0.0

#add percentage magic damage to type
@export var add_dealt_magic_dmg_to_type : String = "type name"
@export var type_dealt_magic_dmg_scale_add : float = 0.0

#add percent to defense
@export var defense_scale_add : float = 0.0

#add buff on phys dmg
@export var add_buff_on_dealt_phys_dmg : String = ""

#add buff on magic dmg
@export var add_buff_on_dealt_magic_dmg : String = ""

#flat buff on dealt phys dmg
@export var add_dealt_phys_dmg : int = 0

#flat buff on dealt magic dmg
@export var add_dealt_magic_dmg : int = 0

func get_magic_dmg_scale_add() -> float:
	return magic_dmg_scale_add

func get_phys_dmg_scale_add() -> float:
	return phys_dmg_scale_add

func get_defense_scale_add() -> float:
	return defense_scale_add

func add_buff_phys_dmg() -> String:
	return add_buff_on_dealt_phys_dmg

func add_buff_magic_dmg() -> String:
	return add_buff_on_dealt_magic_dmg

func get_type_phys() -> String:
	return add_buff_on_dealt_phys_dmg

func get_type_dealt_phys_dmg_scale_add() -> float:
	return type_dealt_phys_dmg_scale_add

func get_add_dealt_phys_dmg_to_type() -> String:
	return add_dealt_phys_dmg_to_type

func get_type_dealt_magic_dmg_scale_add() -> float:
	return type_dealt_phys_dmg_scale_add

func get_add_dealt_magic_dmg_to_type() -> String:
	return add_dealt_phys_dmg_to_type
