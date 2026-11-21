class_name  EquipItemSummary extends Node2D

func set_equip_item(equip_item : EquipItem):
	if(equip_item != null):
		var item_name : String = equip_item.get_item_name_text()
		$equip_item_label.parse_bbcode(item_name)
		var item_description : String = equip_item.get_description()
		$description_label.parse_bbcode(item_description)
		var item_sprite : SpriteFrames = equip_item.get_sprite_frames()
		$sprite.sprite_frames = item_sprite
		$sprite.play("default")
