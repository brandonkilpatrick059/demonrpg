extends Label

var timer := Timer.new()
var fading_in : bool = false
var fading_out : bool = false
var fader_ref : FadeNode = null

func _ready() -> void:
	modulate = Color(1,1,1,0)
	timer.one_shot = true
	add_child(timer)

func display_text(new_text : String):
	modulate = Color(1,1,1,0)
	text = new_text
	fading_in = true
	fader_ref = load("res://utility/faders/fade_node.tscn").instantiate()
	fader_ref.set_target_modulate(Color(1,1,1,1),0.2,0.4)
	add_child(fader_ref)

func _physics_process(delta: float) -> void:
	if(fading_in and fader_ref == null):
		fading_in = false
		timer.start(5.0)
	elif(timer.is_stopped() and not fading_out and fader_ref == null):
		fading_out = true
		fader_ref = load("res://utility/faders/fade_node.tscn").instantiate()
		fader_ref.set_target_modulate(Color(1,1,1,0),0.2,0.2)
		add_child(fader_ref)
	elif(fading_out and fader_ref == null):
		fading_out = false
