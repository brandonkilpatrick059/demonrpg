class_name BattleSystemManager extends Node

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
