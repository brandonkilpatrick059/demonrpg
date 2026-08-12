extends CanvasLayer

var active : bool = false

func set_active():
	active = true

func set_inactive():
	active = false

func is_active() -> bool:
	return active
