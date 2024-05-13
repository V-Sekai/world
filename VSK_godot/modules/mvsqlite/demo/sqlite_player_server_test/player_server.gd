# Create 80 player nodes, each on a separate SQLite database on a TBD CPU bare metal machine
extends Node

class_name Player
var id : String
var state : PackedByteArray

var dbs: Array[MVSQLite] = []
var http_request = HTTPRequest.new()

var insert_query = null

func create_new_player() -> Player:
	var player := Player.new()
	player.id = generate_uuid()
	player.state = PackedByteArray()
	return player
	
func _ready():
	self.add_child(http_request)
	http_request.connect("request_completed", _on_request_completed)

	var player = create_new_player()

	var err = http_request.request("http://localhost:7001/api/create_namespace",
								   ["Content-Type: application/json"],
								   HTTPClient.METHOD_POST,
								   '{"key":"' + player.id + '"}')

	if err == OK:
		print("Player database created")
	else:
		print("Error sending request")

	for i in 100:
		var db = MVSQLite.new()
		if db.open(str(i)):
			dbs.append(db)
		else:
			print("Error opening database: ", db.get_last_error_message())
		if db.open(player.id):
			var sql := "CREATE TABLE IF NOT EXISTS players (id TEXT PRIMARY KEY, state BLOB)"
			var query = db.create_query(sql)
			query.execute()

			sql = "INSERT INTO players (id, state) VALUES (?, ?)"
			insert_query = db.create_query(sql)

func update_player_states(players):
	for player in players:
		# TODO: open player databases
		var db = dbs[player.id % 100]
		var sql := "INSERT OR REPLACE INTO players (id, state) VALUES (?, ?)"
		var query = db.create_query(sql)
		var result = query.execute([player.id, player.state])
		print_verbose("Upsert ID, state [%s, %s]" % [player.id, player.state])


func _process(_delta):
	var crypto: Crypto = Crypto.new()
	var bytes: PackedByteArray = crypto.generate_random_bytes(100)

	var player = create_new_player()
	player.state = bytes
	print_verbose("Insert ID, state [%s, %s]" % [player.id, player.state])

	insert_query.execute([player.id, player.state])


func _on_request_completed(result, response_code, headers, body):
	var str = body.get_string_from_utf8()
	if response_code == 200:
		print("Request completed successfully")
	else:
		print("Request failed with response code: ", response_code)
		print("Response body: ", str)

func generate_uuid() -> String:
	var crypto: Crypto = Crypto.new()
	var uuid: PackedByteArray = crypto.generate_random_bytes(16)
	return "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % [
		uuid[0], uuid[1], uuid[2], uuid[3], uuid[4], uuid[5], uuid[6], uuid[7],
		uuid[8], uuid[9], uuid[10], uuid[11], uuid[12], uuid[13], uuid[14], uuid[15]
	]

func _exit_tree():
	for db in dbs:
		db.close()
