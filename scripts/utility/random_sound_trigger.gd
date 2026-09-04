extends AudioStreamPlayer2D

@export var sounds : Array[AudioStream] = []

@export var min_wait_secs : float = 0.0
@export var max_wait_secs : float = 1.0

var timer := Timer.new()

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	start_timer()

func start_timer():
	timer.start(randf_range(min_wait_secs,max_wait_secs))

func _physics_process(delta: float) -> void:
	if timer.is_stopped():
		stream = sounds[randi_range(0,sounds.size()-1)]
		var player_ref : Player = get_tree().get_first_node_in_group("player")
		if(not player_ref.is_in_battle()):
			play()
		start_timer()
