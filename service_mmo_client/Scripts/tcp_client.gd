extends Node

var ip_address: String = "localhost"
var port: int = 7000

# Create a StreamPeerTCP instance to manage the TCP connection
var tcp_connection: StreamPeerTCP = StreamPeerTCP.new()

# Add a signal definition at the top of the script
signal send_login()
signal user_connected(username)
signal in_battle(data)
signal discardItem(status, message)
signal chat(type, username, mapID, message)
signal status(data)
signal noteAdded(status, message)
signal extractSuccess(mineral, message)
signal extractFailure(message)
signal unknown_action(data)
signal user_disconnected(username)
signal login_complete(data)
signal mapload_start(count)
signal map_part(data, count)
signal mapload_complete()
signal trigger(data, x, y)
signal teleported(username, x, y)
signal next_map(username, x, y)
signal previous_map(username, x, y)
signal moved_character(username, x, y)
signal exp_increase(data)
signal exp_decrease(data)
signal level_increase(data)
signal level_decrease(data)
signal moved_weapon(data)
signal weapon_equipped(data)
signal moved_armor(data)
signal armor_equipped(data)
signal healed(data)
signal weapon_broke(data)
signal armor_broke(data)
signal attack_missed(enemy)
signal enemy_killed(damage, enemy)
signal damage_dealth(damage, enemy)
signal enemy_missed(enemy)
signal you_died(damage, enemy)
signal damage_received(damage, enemy, character)
signal escaped(enemy)
signal battle_started(enemy)
signal battle_ended(message)
signal took_inventory(name, inventory)
signal took_weapon(name, weapon)
signal took_armor(name, armor)
signal dead_enemies(data)
signal inventory(data)
signal item_discarded(data)
signal unequpped_armor(data)
signal unequpped_weapon(data)
signal shrine_used(data)
signal shrine_healed(data)
signal shrine_item(data)
signal shrine_weapon(data)
signal shrine_armor(data)
signal connected_clients(data)
signal error(type)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if tcp_connection.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		return
	# Check if any data is available to read
	if tcp_connection.get_available_bytes() > 0:
		print("Data Found, parsing...")
		# Read the data from the socket
		var data = tcp_connection.get_data(tcp_connection.get_available_bytes())
		if data.size() > 0:
			var dstr = data[1].get_string_from_utf8()
			#print(dstr.substr(0, 4096))
			if (dstr.length() <= 0):
				return
				
			# Parse the JSON payload
			var json = JSON.new()
			var payload = json.parse(dstr)
			if payload.error == OK:
				# Use a match statement to check against the "action" variable
				handle_received_message(payload, dstr)
			else:
				print("Invalid JSON payload received: %s" % [dstr.substr(0, 256)])
		else:
			print("Disconnected from %s:%s" % [ip_address, port])
			# Stop processing to close the connection
			set_process(false)

# Add this new function after the _ready function
func connect_and_send_username(username: String):
	# Attempt to connect to the IP address and port
	var error = tcp_connection.connect_to_host(ip_address, port)

	if error == OK:
		print("Connected to %s:%s" % [ip_address, port])
		# Send the username to the server
		send_username(username)
		# Keep the connection open
		set_process(true)
	else:
		print("Failed to connect to %s:%s" % [ip_address, port])

# Update the send_username function to remove the username argument
func send_username(username: String):
	print("Sending Username: %s" % [username])
	var data_to_send = {
		"action": "username",
		"message": username
	}
	send_json(tcp_connection, data_to_send)

func send_json(tcp_connection: StreamPeerTCP, data: Dictionary) -> void:
	var json: JSON = JSON.new()
	var json_string: String = json.stringify(data)
	# Send the length of the data followed by the JSON string itself
	var error = tcp_connection.put_data(json_string.to_utf8_buffer())
	if error != OK:
		print("Failed to send username")

func _exit_tree():
	# Close the connection when the node is removed from the scene tree
	tcp_connection.disconnect_from_host()

func handle_received_message(payload, dstr):

	var action = payload.result["action"]

	match action:
				"send_login":
					emit_signal("send_login")
				"user_connected":
					emit_signal("user_connected", payload.result["username"])
				"chat":
					emit_signal("chat", payload.result["type"], payload.result["username"], payload.result["message"])
				"in_battle":
					emit_signal("in_battle", payload.result["data"])
				"discardItem":
					emit_signal("discardItem", payload.result["status"], payload.result["message"])
				"chat":
					emit_signal("chat", payload.result["type"], payload.result["username"], payload.result["mapID"], payload.result["message"])
				"status":
					emit_signal("status", payload.result["data"])
				"noteAdded":
					emit_signal("noteAdded", payload.result["status"], payload.result["message"])
				"extractSuccess":
					emit_signal("extractSuccess", payload.result["mineral"], payload.result["message"])
				"extractFailure":
					emit_signal("extractFailure", payload.result["message"])
				"unknown_action":
					emit_signal("unknown_action", payload.result["data"])
				"user_disconnected":
					emit_signal("user_disconnected", payload.result["username"])
				"login_complete":
					emit_signal("login_complete", payload.result["data"])
				"mapload_start":
					emit_signal("mapload_start", payload.result["count"])
				"map_part":
					emit_signal("map_part", payload.result["data"], payload.result["count"])
				"mapload_complete":
					emit_signal("mapload_complete")
				"trigger":
					emit_signal("trigger", payload.result["data"], payload.result["x"], payload.result["y"])
				"teleported":
					emit_signal("teleported", payload.result["username"], payload.result["x"], payload.result["y"])
				"next_map":
					emit_signal("next_map", payload.result["username"], payload.result["x"], payload.result["y"])
				"previous_map":
					emit_signal("previous_map", payload.result["username"], payload.result["x"], payload.result["y"])
				"moved_character":
					emit_signal("moved_character", payload.result["username"], payload.result["x"], payload.result["y"])
				"exp_increase":
					emit_signal("exp_increase", payload.result["data"])
				"exp_decrease":
					emit_signal("exp_decrease", payload.result["data"])
				"level_increase":
					emit_signal("level_increase", payload.result["data"])
				"level_decrease":
					emit_signal("level_decrease", payload.result["data"])
				"moved_weapon":
					emit_signal("moved_weapon", payload.result["data"])
				"weapon_equipped":
					emit_signal("weapon_equipped", payload.result["data"])
				"moved_armor":
					emit_signal("moved_armor", payload.result["data"])
				"armor_equipped":
					emit_signal("armor_equipped", payload.result["data"])
				"healed":
					emit_signal("healed", payload.result["data"])
				"weapon_broke":
					emit_signal("weapon_broke", payload.result["data"])
				"armor_broke":
					emit_signal("armor_broke", payload.result["data"])
				"attack_missed":
					emit_signal("attack_missed", payload.result["enemy"])
				"enemy_killed":
					emit_signal("enemy_killed", payload.result["damage"], payload.result["enemy"])
				"damage_dealth":
					emit_signal("damage_dealth", payload.result["damage"], payload.result["enemy"])
				"enemy_missed":
					emit_signal("enemy_missed", payload.result["enemy"])
				"you_died":
					emit_signal("you_died", payload.result["damage"], payload.result["enemy"])
				"damage_received":
					emit_signal("damage_received", payload.result["damage"], payload.result["enemy"], payload.result["character"])
				"escaped":
					emit_signal("escaped", payload.result["enemy"])
				"battle_started":
					emit_signal("battle_started", payload.result["enemy"])
				"battle_ended":
					emit_signal("battle_ended", payload.result["message"])
				"took_inventory":
					emit_signal("took_inventory", payload.result["name"], payload.result["inventory"])
				"took_weapon":
					emit_signal("took_weapon", payload.result["name"], payload.result["weapon"])
				"took_armor":
					emit_signal("took_armor", payload.result["name"], payload.result["armor"])
				"dead_enemies":
					emit_signal("dead_enemies", payload.result["data"])
				"inventory":
					emit_signal("inventory", payload.result["data"])
				"item_discarded":
					emit_signal("item_discarded", payload.result["data"])
				"unequpped_armor":
					emit_signal("unequpped_armor", payload.result["data"])
				"unequpped_weapon":
					emit_signal("unequpped_weapon", payload.result["data"])
				"shrine_used":
					emit_signal("shrine_used", payload.result["data"])
				"shrine_healed":
					emit_signal("shrine_healed", payload.result["data"])
				"shrine_item":
					emit_signal("shrine_item", payload.result["data"])
				"shrine_weapon":
					emit_signal("shrine_weapon", payload.result["data"])
				"shrine_armor":
					emit_signal("shrine_armor", payload.result["data"])
				"connected_clients":
					emit_signal("connected_clients", payload.result["data"])
				"error":
					emit_signal("error", payload.result["type"])
				_:
					print("Unknown action received: %s" % payload.result["action"])
	
