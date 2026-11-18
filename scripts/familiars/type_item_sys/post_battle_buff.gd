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

#add buff on phys dmg
@export var add_buff_on_dealt_phys_dmg : BattleBuff = null

#add buff on magic dmg
@export var add_buff_on_dealt_magic_dmg : BattleBuff = null

#flat buff on dealt phys dmg
@export var add_dealt_phys_dmg : int = 0

#flat buff on dealt magic dmg
@export var add_dealt_magic_dmg : int = 0

func get_magic_dmg_scale_add() -> float:
	return magic_dmg_scale_add

func get_phys_dmg_scale_add() -> float:
	return phys_dmg_scale_add
