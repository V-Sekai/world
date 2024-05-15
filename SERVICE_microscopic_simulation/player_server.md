# Player Server with player State Input and Processing

The first application will handle player state input, LCRS processing, and other related tasks.

Each player server handles 8_000 clients.

```gdscript
extends Node

var player_state = {
    # Player state fields...
}

var player_state_map = {}

var root = null

var rb = []

func _ready():
    if not initialize_ring_buffer(100):
        print("Failed to create ring buffer")
        return

func _process(_delta):
        root = select_root_player_state()
        organize_states_into_LCRS_tree(rb, root)
        apply_states_to_all_clients(rb, root)
        var state = receive_player_state_packet_from_UDP_at_100Hz()
        store_state_in_ring_buffer(rb, state)

func initialize_ring_buffer(size):
    for i in range(size):
        rb.append(null)
    return true

func select_root_player_state():
    if len(rb) > 0:
        return rb[-1]
    else:
        return null

func organize_states_into_LCRS_tree(rb, root):
    pass

# Apply states to all clients
func apply_states_to_all_clients(rb, root):
    pass

# Receive player state packet from UDP at 100Hz
func receive_player_state_packet_from_UDP_at_100Hz():
    pass

func store_state_in_ring_buffer(rb, state):
    # Remove the oldest state
    rb.pop_front()

    # Add the new state
    rb.push_back(state)
```

## Attribution

    Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
    SaracenOne & K. S. Ernest (Fire) Lee & Lyuma & MMMaellon & Contributors
    player_server.md
    SPDX-License-Identifier: MIT
