class_name BattleSystemManager extends Node

@onready var action_menu : BattleActionMenu = $BattleActionMenu
@onready var message : BattleMessage = $BattleMessage
@onready var status : BattleStatus = $BattleStatus
@onready var hp_gauge : HPGauge = $hp_gauge

@export var opponent_familiars : Array[Familiar] = []
@export var player_familiars : Array[Familiar] = []

var opponent_positions : Array[Node] = [
	$"familiars/opponent/1",
	$"familiars/opponent/2",
	$"familiars/opponent/3",
	$"familiars/opponent/4"
]

var player_positions : Array[Node] = [
	$"familiars/player/1",
	$"familiars/player/2",
	$"familiars/player/3",
	$"familiars/player/4"
]

var battle_timer := Timer.new()

func _ready() -> void:
	hide_all_interface()
	battle_timer.one_shot = true
	add_child(battle_timer)

func hide_all_interface():
	action_menu.visible = false
	message.visible = false
	status.visible = false
	hp_gauge.visible = false
