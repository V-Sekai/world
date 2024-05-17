# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# player_client.gd
# SPDX-License-Identifier: MIT

extends Node

var socket = PacketPeerUDP.new()
var player_id = "0001" # Replace with actual player ID

func _ready():
    var error = socket.connect_to_host("localhost", 8000)
    if error == OK:
        print("Connected to server.")
    else:
        print("Failed to connect to server.")

func send_player_state(state):
    var msg = player_id + state
    socket.put_packet(msg.to_utf8())
