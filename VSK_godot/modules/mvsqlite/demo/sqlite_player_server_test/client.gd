extends Node

class_name Runner

var players: Array[Player] = []

func _ready():
	for i in range(1):
		var player: Player = Player.new()
		player.process_thread_group = Node.PROCESS_THREAD_GROUP_SUB_THREAD
		players.append(player)
		add_child(player, true)

