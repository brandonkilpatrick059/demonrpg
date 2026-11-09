extends AudioStreamPlayer

@export var zero_db : float = -60.0
@export var throttle_to_db : float = 0.0
@export var db_step : float = 1.0
@export var db_step_time_secs : float = 0.005

var timer := Timer.new()

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	volume_db = zero_db
	play()

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		if(volume_db < throttle_to_db):
			volume_db = volume_db + db_step
		elif(volume_db > throttle_to_db):
			volume_db = throttle_to_db
		timer.start(db_step_time_secs)
