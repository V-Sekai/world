extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Set the IP address and port for the connection

var discord_url = "https://discord.gg/pTGZuaf"


# Define the terrain scene or resource that you want to instantiate
var terrain_scene = preload("res://Assets/terrain.tscn")

# Define the player scene or resource that you want to instantiate
var player_scene = preload("res://Assets/player.tscn")

# Define the map scene or resource that you want to instantiate into
var map_scene = preload("res://Assets/map.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	pass




func process_map_event(map_data):
	var map = map_scene.instance()
	for map_object in map_data:
		for map_cell in map_object:
			var x = map_cell["x"]
			var y = map_cell["y"]

			# Instantiate a square and add it to the scene at the specified position
			var terrain = terrain_scene.instance()
			terrain.set("TYPE", map_cell["type"]) # Set the TYPE property of the square scene
			terrain.position = Vector2(x, y)
			map.add_child(terrain)
	if get_tree().change_scene(map_scene) != OK:
		print("Failed to Load Map.")



# Update the process_spawn_player_event function to include X and Y position arguments
func process_spawn_player_event(player_id, player_name, x, y):
	# Instantiate a square and add it to the scene
	var player = player_scene.instance()
	player.set("ID", player_id) # Set the ID property of the square scene
	player.set("Name", player_name) # Set the Name property of the square scene
	player.position = Vector2(x, y) # Set the X and Y position of the square scene
	map_scene.add_child(player)

# Add this new function after the process_spawn_player_event function
func process_move_event(player_id, x, y):
	# Find the square scene with the matching ID
	for child in map_scene.get_children():
		if child.get("ID", -1) == player_id:
			# Set the new X and Y position for the square scene
			child.position = Vector2(x, y)
			break

# Add this new function after the process_move_event function
func process_say_event(username, message):
	# Trigger the global event by emitting the message_received signal
	emit_signal("message_received", username, message)

# Documentation should be something like this, inside of the chat window
#func _ready():
#    # Replace "TCP_Connection_Node" with the actual node name or path
#    $TCP_Connection_Node.connect("message_received", self, "_on_message_received")
#
#func _on_message_received(username, message):
#    # Handle the received message and username
#    print("%s: %s" % [username, message])
