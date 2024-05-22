**Controls:**

- Grip button: Grab or release cube
- Index button: Attach cube to hand
- Stick up/down + combination (Press X button): Move held cube in/out and rotate on Y-axis
- Stick left/right + combination (Press Y button): Rotate held cube on X-axis

**Scenes:**

1. Loopback
2. Host
3. Guest

## Loopback

Start with the "Loopback" scene in the "Scenes" folder for the networked physics demo.

The loopback scene mimics a network connection between a host and guest in one app. The host is the initial set of cubes you spawn. The guest is the set of cubes on the right. Actions in either simulation are mirrored via a virtual network. Switch between host context (cubes turn blue) and guest context (cubes turn red) using "A" and "B" buttons on your touch controller. Press "SPACE" to reset.

## Host and guest

Next, run a host and guest. The host serves as a server for up to three other players. Guests use the lobby server to find a host. Press "SPACE" as host to reset. Guests pressing "SPACE" disconnect and return to the lobby server to find a new host. If there's only one host, guests will reconnect.
