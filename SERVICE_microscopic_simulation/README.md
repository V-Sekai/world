# ebpf prototypes

## **UDP Monitor and Forwarder (8_000_PlayerServer to 10_000_WorldServerLeader)**

```bash
iptables -t nat -A PREROUTING -p udp --dport 8000 -j DNAT --to-destination <IP of 10_000_WorldServerLeader>:10000
```

This rule tells `iptables` to take any UDP packets that arrive on port 8000 and forward them to the IP address of `10_000_WorldServerLeader` on port 10000. You'd replace `<IP of 10_000_WorldServerLeader>` with the actual IP address of your `10_000_WorldServerLeader` server.

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```

## UDP Responder (10_000_WorldServerLeader to SingleClient)\*\*:

```python
#!/usr/bin/python3
from bcc import BPF
import socket
import time

program = r"""
// Your BPF program goes here
// Get the operation from 8_000_PlayerServer
// (task, pid, cpu, flags, ts, msg) = b.trace_fields()
// write ring buffer states to the map.
// on updates of the map send back the processed data to the SingleClient
"""

device = "eth0"
b = BPF(text=program)
b.attach_xdp(device, fn_name="responder_xdp_filter")

def process_data(states):
    sorted_states = sort_states_with_left_child_right_sibling_binary_tree(player_states)
    interpolated_states = interpolate_states(sorted_states)

while True:
    try:
        states = [(k.value, v.value) for k, v in ring_buffer_states.items()]
        processed_data = process_data(states)

    except KeyboardInterrupt:
        break
```

## Attribution

    Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
    K. S. Ernest (Fire) Lee & Contributors
    README.md
    SPDX-License-Identifier: MIT
