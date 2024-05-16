# 1_000_000 player fps

By aiming high, 100 players will be easy.

1. Player state nodes are isolated; you can observe others but interaction is not possible.
2. Each individual player state is processed in tree order for all states within the frame, then stored back into the player state.
3. All player states are stored in a history buffer for one second for interpolation and other processes, then sent to the player simultaneously.

Glenn suggests multiple servers, but I believe they can be simulated on a single Godot engine through parallel processing, sequential processing, or reduction.

According to https://two-wrongs.com/response-time-is-the-system-talking.html run production systems at 40% at all times.

## Player Servers (Linux kernel ebpf module)

Player simulation means the game code that takes player inputs and moves the player around the world, collides with world geometry, and eventually also lets the player aim and shoot weapons.

The assumptions necessary to make player servers work are:

- The world is static.
- Each player server has a static representation of the world that allows for collision detection to be performed between the player and the world.
- Players do not physically collide with each other.
- Each player server has 8,000 players on and distributed across 32 CPUs.
- Each state is 100 bytes long.
- Each player updates at 100 requests per-second.
- These CPUs have 90% of CPU still available to do work because they are otherwise IO bound.
- The player server then forwards the player states to the world server.
- There is no global tick on a player server.

## World database (Linux userland application server)

The player server exposes a blocking Linux file descriptor that the player database can read and write.

The world database that operates on all the blocking game state file descriptors so that the players can interact with the world and other objects.

## World Servers (Linux kernel ebpf module)

The 1 second history ring buffer is used for lag compensation and potentially also delta compression.

https://www.kernel.org/doc/html/next/bpf/ringbuf.html

Each player state is 100 bytes, so 100 x 100 x 10,000 = 100,000,000 bytes of memory required or 100 megabytes

(We spoof the packet in the Linux Kernel ebpf program so it appears that it comes from the player server address.)

The world server has a complete historical record of all other player states going back one second.

10,000 players per-world server, and we need to store a history of each player for 1 second at 100HZ.

Each deep player state that is sent back to the owning client for client side prediction rollback and re-simulation is 1000 bytes.

The shallow player state required for interpolation and display in the remote view of a player is much smaller – assume 100 bytes.

Increasing the buffer to 10 seconds of ring buffer history is only 1 gigabyte instead of 100 megabytes.

## Game State Delivery

Each world server generates a stream of just 100 mbit/sec containing all player states for 10,000 players @ 100HZ (assuming delta compression against a common baseline once every second), and we have 100 world servers.

100 mbit x 100 = 10 gbit generated per-second.

But there are 10,000 players per-world server. And each of these 10,000 players need to receive the same 100mbit/sec stream of packets from the world server. Welcome to O(n^2).

## References

https://github.com/V-Sekai-fire/udp/blob/main/010/server_xdp.c

https://mas-bandwidth.com/creating-a-first-person-shooter-that-scales-to-millions-of-players/

## Other stuff

https://github.com/xdp-project/xdp-tutorial/tree/master/basic04-pinning-maps

https://gafferongames.com/post/networked_physics_in_virtual_reality/

https://github.com/V-Sekai-fire/udp/blob/main/010/server_xdp.c

```
public struct CubeState
{
public bool active;

    public int authorityIndex;
    public ushort authoritySequence;
    public ushort ownershipSequence;

    public int position_x;
    public int position_y;
    public int position_z;

    public uint rotation_largest;
    public uint rotation_a;
    public uint rotation_b;
    public uint rotation_c;

    public int linear_velocity_x;
    public int linear_velocity_y;
    public int linear_velocity_z;

    public int angular_velocity_x;
    public int angular_velocity_y;
    public int angular_velocity_z;

    public static CubeState defaults;

     // Pad to 100 bytes
     [MarshalAs(UnmanagedType.ByValArray, SizeConst = 43)]
     public byte[] padding;

};
```

## Relay server design

clients <-> player servers

player server <-> world server

We apply the relay apply state algorithm for choose entity authority vs entity ownership instead of a world database.

We call these entity players but some are cubes that are parented (attached/glued) to players.

This function determines when we should apply state updates to cubes.

It is designed to allow clients to pre-emptively take authority over cubes when
they grab and interact with them indirectly (eg. throwing cubes at other cubes).

In short, ownership sequence increases each time a player grabs a cube, and authority
sequence increases each time a cube is touched by a cube under authority of that player.

When a client sees a cube under its authority has come to rest, it returns that cube to
default authority and commits its result back to the server. The logic below implements
this direction of flow, as well as resolving conflicts when two clients think they both
own the same cube, or have interacted with the same cube. The first player to interact,
from the point of view of the server (client 0), wins.

https://github.com/fbsamples/oculus-networked-physics-sample/blob/main/Networked%20Physics/Assets/Scripts/AuthoritySystem.cs#L29

While it makes intuitive sense that taking authority (acting like the server) for objects you interact can hide latency – since, well if you’re the server, you don’t experience any lag, right? – what’s not immediately obvious is how to resolve conflicts.
What if two players interact with the same stack? What if two players, masked by latency, grab the same cube? In the case of conflict: who wins, who gets corrected, and how is this decided?

We implement this as an encoding in the state exchanged between players over my network protocol, rather than as events.

Each cube would have authority, either set to default (white), or to whatever color of the player that last interacted with it. If another player interacted with an object, authority would switch and update to that player. I planned to use authority for interactions of thrown objects with the scene. I imagined that a cube thrown by player 2 could take authority over any objects it interacted with, and in turn any objects those objects interacted with, recursively.

Ownership was a bit different. Once a cube is owned by a player, no other player could take ownership until that player reliquished ownership. I planned to use ownership for players grabbing cubes, because I didn’t want to make it possible for players to grab cubes out of other player’s hands after they picked them up.

We represent and communicate authority and ownership as state by including two different sequence numbers a per-cube authority sequence, and an ownership sequence number.

## Design goals

1. **Players should be able to pick up, throw and catch cubes without latency.**

If you consider a player and the cube they're interacting with as two nodes, when a player picks up a cube, you could say that the player becomes the parent node of the cube in the LCRS tree.

2. **Players should be able to stack cubes, and these stacks should be stable (come to rest) and be without visible jitter.**

When cubes are stacked, each cube that is placed on top of another could be considered a child of the cube below it. The bottom cube acts as the parent node, and the cubes stacked on top are its children in the LCRS tree.

3. **When cubes thrown by any player interact with the simulation, wherever possible, these interactions should be without latency.**

If you consider the player and the cube as two nodes, when a player throws a cube, the player could be considered the parent node of the cube in the LCRS tree until the cube interacts with another object or player.
