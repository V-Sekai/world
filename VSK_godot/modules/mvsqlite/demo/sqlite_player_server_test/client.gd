extends Node

class_name Runner

var players: Array[Player] = []

func _ready():
	for i in range(80):
		var player = Player.new()
		players.append(player)
		add_child(player, true)
