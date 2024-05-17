```
brew install lima
lima --version
limactl version 0.16.0
mkdir -p ~/Desktop/epbf-mac-arm-tutorial
cd ~/Desktop/epbf-mac-arm-tutorial
```

```
cat <<EOF > ubuntu-lts-ebpf.yaml
images:
# Try to use release-yyyyMMdd image if available. Note that release-yyyyMMdd will be removed after several months.
- location: "https://cloud-images.ubuntu.com/releases/22.04/release-20230518/ubuntu-22.04-server-cloudimg-amd64.img"
  arch: "x86_64"
  digest: "sha256:afb820a9260217fd4c5c5aacfbca74aa7cd2418e830dc64ca2e0642b94aab161"
- location: "https://cloud-images.ubuntu.com/releases/22.04/release-20230518/ubuntu-22.04-server-cloudimg-arm64.img"
  arch: "aarch64"
  digest: "sha256:b47f8be40b5f91c37874817c3324a72cea1982a5fdad031d9b648c9623c3b4e2"
# Fallback to the latest release image.
- location: "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
  arch: "x86_64"
- location: "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-arm64.img"
  arch: "aarch64"

memory: "2GiB"
cpus: 2
disk: "30GiB"
ssh:
  # You can choose any port or omit this. Specifying a value ensures same port bindings after restarts
  # Forwarded to port 22 of the guest.
  localPort: 2222
# We are going to install all the necessary packages for our development environment.
# These include Python 3 and the bpfcc tools package.
provision:
  - mode: system
    script: |
      #!/bin/bash
      set -eux -o pipefail
      export DEBIAN_FRONTEND=noninteractive
      apt update && apt-get install -y vim python3 bpfcc-tools linux-headers-$(uname -r)
  - mode: user
    script: |
      #!/bin/bash
      set -eux -o pipefail
      sudo cp /home/$(whoami).linux/.ssh/authorized_keys /root/.ssh/authorized_keys
EOF
```

```
limactl start --name=ebpf-lima-vm ./ubuntu-lts-ebpf.yaml
```

```
#!/usr/bin/python3
from bcc import BPF

program = r"""
int hello(void *ctx) {
    bpf_trace_printk("Hello Mac. I am an eBPF program!");
    return 0;
}
"""
b = BPF(text=program)
syscall = b.get_syscall_fnname("execve")
b.attach_kprobe(event=syscall, fn_name="hello")
b.trace_print()
```

```
limactl shell ebpf-lima-vm
```

## Prototype ebf. (Work in Progress)

1. **UDP Monitor and Forwarder (8_000_PlayerServer to 10_000_WorldServerLeader)**

```python
#!/usr/bin/python3
from bcc import BPF

program = r"""
#include <uapi/linux/ptrace.h>
#include <net/sock.h>
#include <bcc/proto.h>

struct ipkey {
    u32 src_ip;
    u32 dst_ip;
    u16 src_port;
    u16 dst_port;
};

BPF_HASH(pkt_count, struct ipkey);

int udp_monitor(struct __sk_buff *skb) {
    u8 *cursor = 0;

    struct ethernet_t *ethernet = cursor_advance(cursor, sizeof(*ethernet));
    struct ip_t *ip = cursor_advance(cursor, sizeof(*ip));
    struct udp_t *udp = cursor_advance(cursor, sizeof(*udp));

    struct ipkey key = {};
    key.src_ip = ip->src;
    key.dst_ip = ip->dst;
    key.src_port = udp->src_port;
    key.dst_port = udp->dst_port;

    u64 zero = 0, *val;
    val = pkt_count.lookup_or_init(&key, &zero);
    (*val)++;

    return 0;
}

"""

b = BPF(text=program)
b.attach_kprobe(event="udp_rcv", fn_name="udp_monitor")

while True:
    try:
        (task, pid, cpu, flags, ts, msg) = b.trace_fields()
        print("%-18.9f %-16s %-6d %s" % (ts, task, pid, msg))
    except KeyboardInterrupt:
        break
```

2. **UDP Responder (10_000_WorldServerLeader to SingleClient)**

```python
#!/usr/bin/python3
from bcc import BPF
import socket
import struct

program = r"""
#include <uapi/linux/ptrace.h>
#include <net/sock.h>
#include <bcc/proto.h>

struct ipkey {
    u32 src_ip;
    u32 dst_ip;
    u16 src_port;
    u16 dst_port;
};

BPF_HASH(response_count, struct ipkey);

int udp_responder(struct __sk_buff *skb) {
    u8 *cursor = 0;

    struct ethernet_t *ethernet = cursor_advance(cursor, sizeof(*ethernet));
    struct ip_t *ip = cursor_advance(cursor, sizeof(*ip));
    struct udp_t *udp = cursor_advance(cursor, sizeof(*udp));

    struct ipkey key = {};
    key.src_ip = ip->src;
    key.dst_ip = ip->dst;
    key.src_port = udp->src_port;
    key.dst_port = udp->dst_port;

    u64 zero = 0, *val;
    val = response_count.lookup_or_init(&key, &zero);
    (*val)++;

    return 0;
}

"""

b = BPF(text=program)
b.attach_kprobe(event="udp_sendmsg", fn_name="udp_responder")

while True:
    try:
        (task, pid, cpu, flags, ts, msg) = b.trace_fields()
        print("%-18.9f %-16s %-6d %s" % (ts, task, pid, msg))
    except KeyboardInterrupt:
        break
```

3. **Iterator and Interpolator (10_000_WorldServerLeader)**

```python
#!/usr/bin/python3
from bcc import BPF
import struct

program = r"""
#include <uapi/linux/ptrace.h>
#include <net/sock.h>
#include <bcc/proto.h>

struct player_state {
    u64 timestamp;
    u32 x;
    u32 y;
};

BPF_HASH(player_states, u32, struct player_state);

int iterator_interpolator(struct __sk_buff *skb) {
    u8 *cursor = 0;

    struct ethernet_t *ethernet = cursor_advance(cursor, sizeof(*ethernet));
    struct ip_t *ip = cursor_advance(cursor, sizeof(*ip));
    struct udp_t *udp = cursor_advance(cursor, sizeof(*udp));

    u32 key = ip->src;
    struct player_state *state = player_states.lookup(&key);
    if (state) {
        // Perform interpolation here.
    } else {
        struct player_state init_state = {};
        init_state.timestamp = bpf_ktime_get_ns();
        init_state.x = 0;
        init_state.y = 0;
        player_states.update(&key, &init_state);
    }

    return 0;
}

"""

b = BPF(text=program)
b.attach_kprobe(event="udp_sendmsg", fn_name="iterator_interpolator")

while True:
    try:
        (task, pid, cpu, flags, ts, msg) = b.trace_fields()
        print("%-18.9f %-16s %-6d %s" % (ts, task, pid, msg))
    except KeyboardInterrupt:
        break
```

This program monitors outgoing packets at the `10_000_WorldServerLeader` and maintains a BPF hash map of player states. The keys of the map are the source IP addresses of the packets. The values are structures containing a timestamp and the x and y coordinates of the player. The program updates the player state for each packet.

Please note that this is a basic implementation and does not include the functionality to sort the states using a Left-child right-sibling binary tree or perform interpolation based on a specific algorithm.
