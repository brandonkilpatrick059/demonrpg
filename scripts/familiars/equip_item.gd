class_name EquipItem extends Node

var item_name: String = "DEVIL FANG"
@export var name_text : Text = null
@export var description_text : Text = null
@export var sprite_frames : SpriteFrames = null

@export var post_battle_buffs : Array[PostBattleBuff] = []
@export var post_heal_buffs : Array[PostHealBuff] = []
@export var post_feed_buffs: Array[PostFeedBuff] = []
@export var path_to_self : String = ""

#func apply_to_pkg(buff_holder : Familiar, pkg : BattlePkg) -> BattlePkg:
	#return pkg

func get_item_name() -> String:
	return item_name

func get_item_name_text() -> String:
	return name_text.get_text("english")

func get_description() -> String:
	return description_text.get_text("english")

func get_post_heal_buffs() -> Array[PostHealBuff]:
	return post_heal_buffs

func get_post_battle_buffs() -> Array[PostBattleBuff]:
	return post_battle_buffs

func get_post_feed_buffs() -> Array[PostFeedBuff]:
	return post_feed_buffs

func get_sprite_frames() -> SpriteFrames:
	return sprite_frames

func get_path_to_self() -> String:
	return path_to_self
