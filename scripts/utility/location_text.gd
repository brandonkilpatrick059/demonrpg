extends Area2D

@export var location_text : String = ""

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("player")):
		body.display_location_text(location_text)
