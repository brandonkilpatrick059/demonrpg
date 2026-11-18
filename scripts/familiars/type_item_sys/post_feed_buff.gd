class_name PostFeedBuff extends TypeItemBuff

@export var buff_consumed_stat_by : int = 0
@export var buff_consumed_stat_name : String = ""

@export var energy_back : int = 0

func get_buff_consumed_stat_name() -> String:
	return buff_consumed_stat_name

func get_buff_consumed_stat_by() -> int:
	return buff_consumed_stat_by

func get_energy_back_amt() -> int:
	return energy_back
