# World Server Sending Packet Back to Client

Each world server handles 10_000 clients.

```gdscript
extends Node

var udp_server = PacketPeerUDP.new()

var player_state = {
    # Player state fields...
}

# Ring buffer (implemented as an Array)
var rb = []

func _ready():
    initialize_ring_buffer(100)
    udp_server.listen(12345)

func _process(_delta):
        var state = receive_player_state_packet_from_UDP_at_100Hz()
        store_state_in_ring_buffer(rb, state)
        return_state_to_client()

func initialize_ring_buffer(size):
    for i in range(size):
        rb.append(null)

func receive_player_state_packet_from_UDP_at_100Hz():
    if udp_server.wait_packet(10):
        var packet = udp_server.get_packet()
        # Process the packet here
        return packet
    else:
        return null

func store_state_in_ring_buffer(rb, state):
    # Remove the oldest state
    rb.pop_front()

    # Add the new state
    rb.push_back(state)

func return_state_to_client():
    # Send the processed packet back to the original sender
    udp_server.put_packet(player_state)
```

## Attribution

    Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
    SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
    player_server.md
    SPDX-License-Identifier: MIT
