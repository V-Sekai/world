# Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
# K. S. Ernest (Fire) Lee & Contributors
# player_client.gd
# SPDX-License-Identifier: MIT

extends Node

var socket: PacketPeerUDP = PacketPeerUDP.new()
var entity_id: String = "0001"

func _ready() -> void:
    var error: int = socket.connect_to_host("localhost", 8000)
    if error == OK:
        print("Connected to server.")
    else:
        print("Failed to connect to server.")

func send_entity_state(state: PackedByteArray) -> void:
    assert(state.size() == 100)
    var msg: PackedByteArray = state
    socket.put_packet(msg)
