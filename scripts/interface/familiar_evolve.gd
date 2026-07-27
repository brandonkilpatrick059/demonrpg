class_name FamiliarEvolve extends Node2D

var awaiting_input : bool = false

var potential_evolutions : Array[Evolution] = []

var intro : bool = false
var selecting_path : bool = false
var start_selecting_path : bool = false
var start_evolving : bool = false
var evolved : bool = false
var evolving : bool = true
var ready_to_close : bool = false

var evolving_familiars : Array[Familiar] = []
var evolving_familiar : Familiar
var new_evolution : Familiar

var path_index : int = 0

func _ready() -> void:
	$pentagram.modulate = Color(1,1,1,0)
	$arrow_1.visible = false
	$arrow_2.visible = false

func set_evolving_familiars(familiars : Array[Familiar]):
	evolving_familiars.clear()
	for familiar in familiars:
		evolving_familiars.append(familiar)
	evolve_next_familiar()

func evolve_next_familiar():
	var familiar : Familiar = evolving_familiars.pop_back()
	familiar.set_active()
	familiar.reparent(self)
	familiar.z_index = 1
	familiar.position = Vector2(0,0)
	potential_evolutions = familiar.get_evolutions()
	evolving_familiar = familiar
	intro = true

func await_input():
	awaiting_input = true

func end_awaiting_input():
	awaiting_input = false

func play_messages(text_queue : Array[String]):
	$InterfaceMessage.queue_text(text_queue)
	awaiting_input = true

func handle_input():
	if(Input.is_action_just_pressed("right")):
		path_index = path_index + 1
		if(path_index >= potential_evolutions.size()):
			path_index = 0
		$InterfaceMessage.play_text(potential_evolutions[path_index].get_path_text())
	elif(Input.is_action_just_pressed("left")):
		path_index = path_index - 1
		if(path_index < 0):
			path_index = potential_evolutions.size() - 1
		$InterfaceMessage.play_text(potential_evolutions[path_index].get_path_text())
	elif(Input.is_action_just_pressed("action_1")):
		selecting_path = false
		start_evolving = true
		evolving = true
		$arrow_1.visible = false
		$arrow_2.visible = false

func fade_out_pentacle():
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	var fade_out = Color(1,1,1,0)
	fade_node.set_target_modulate(fade_out,0.2,0.2)
	$pentagram.add_child(fade_node)

func fade_in_pentacle():
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	var fade_out = Color(1,1,1,1)
	fade_node.set_target_modulate(fade_out,0.2,0.2)
	$pentagram.add_child(fade_node)

func fade_in_new_evolution():
	var fade_node : FadeNode = load("res://utility/faders/fade_node.tscn").instantiate()
	var fade_out = Color(1,1,1,1)
	fade_node.set_target_modulate(fade_out,0.2,0.2)
	new_evolution.add_child(fade_node)

func close_evolution():
	var player : Player = get_tree().get_first_node_in_group("player")
	var familiar_team = player.get_familiars_team()
	var replace_index = familiar_team.find(evolving_familiar)
	familiar_team.set(replace_index,new_evolution)
	new_evolution.reparent(player)
	new_evolution.set_inactive()
	evolving_familiar.queue_free()
	if(evolving_familiars.size() > 0):
		evolve_next_familiar()
	else:
		player.return_to_overworld()
		queue_free()

func _physics_process(delta: float) -> void:
	if(not awaiting_input):
		if(intro):
			var text_1 : String = $intro_text_1.get_text("english")
			text_1 = text_1.replace("[NAME]",evolving_familiar.get_familiar_name())
			var text_2 : String = $intro_text_2.get_text("english")
			play_messages([text_1,text_2])
			awaiting_input = true
			intro = false
			selecting_path = true
			start_selecting_path = true
		elif(selecting_path):
			if(start_selecting_path):
				$InterfaceMessage.play_text(potential_evolutions[path_index].get_path_text())
				start_selecting_path = false
			$arrow_1.visible = true
			$arrow_2.visible = true
			handle_input()
		elif(evolving):
			if(start_evolving):
				$Timer.start(3.0)
				fade_in_pentacle()
				$AudioStreamPlayer.stream = load("res://audio/effects/capture.ogg")
				$AudioStreamPlayer.play()
				var chosen_evolution : Evolution = potential_evolutions[path_index]
				new_evolution = chosen_evolution.get_evolved_familiar(evolving_familiar)
				new_evolution.modulate = Color(1,1,1,0)
				add_child(new_evolution)
				new_evolution.position = Vector2(0,-6)
				start_evolving = false
			elif($Timer.is_stopped() && !evolved):
				evolving_familiar.kill()
				new_evolution.set_active()
				fade_in_new_evolution()
				$AudioStreamPlayer.stream = load("res://audio/effects/die.ogg")
				$AudioStreamPlayer.play()
				evolved = true
				$Timer.start(2.0)
			elif($Timer.is_stopped() && evolved):
				if(not ready_to_close):
					var text : String = $close_text_1.get_text("english")
					text = text.replace("[NAME1]",evolving_familiar.get_familiar_name())
					text = text.replace("[NAME2]",new_evolution.get_familiar_name())
					$InterfaceMessage.play_text(text)
					awaiting_input = true
					ready_to_close = true
				if(ready_to_close && not awaiting_input):
					evolving = false
					evolved = false
					close_evolution()
					
				
			
