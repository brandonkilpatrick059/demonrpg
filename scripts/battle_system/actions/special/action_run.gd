extends BattleAction

var announced: bool = false
var announced_failure : bool = false

var battle_sys_ref : BattleSystemManager

var announcment_english : String = "You try to run..."
var success_english : String = "You run as fast as you can."
var failure_english : String = "But you cannot."
var success_message : String = ""

var run_succeeded: bool = false

func determine_run_success():
	run_succeeded =  randf_range(0.0,1.0) < 0.5

func _ready() -> void:
	action_name = "RUN"
	target_type = TargetType.NO_TARGET

func clean_up():
	announced = false
	announced_failure = false

func exit_action():
	battle_sys_ref.start_wait_timer(0.5)
	battle_sys_ref.get_next_action()
	clean_up()

func get_summary(actor : Familiar)-> String:
	var summary : String = ""
	summary = str(summary,get_action_name())
	summary = str(summary,"-[color=white]ATTEMPT TO ESCAPE[/color]" )
	return summary

func action_process(actor : Familiar, targets : Array[Familiar]):
	battle_sys_ref = get_tree().get_first_node_in_group("battle_system")
	if(not announced):
		var announcement : String = announcment_english
		battle_sys_ref.play_messages([announcement])
		determine_run_success()
		announced = true
	elif(run_succeeded):
		clean_up()
		battle_sys_ref.run_away()
	elif(not announced_failure && not run_succeeded):
		var comment : String = failure_english
		battle_sys_ref.play_messages([comment])
		announced_failure = true
	else:
		exit_action()
