1. Player state nodes are isolated; you can observe others but interaction is not possible.
2. Each individual player state is processed in tree order for all states within the frame, then stored back into the player state.
3. All player states are stored in a history buffer for one second for interpolation and other processes, then sent to the player simultaneously.

Glenn suggests multiple servers, but I believe they can be simulated on a single Godot engine through parallel processing, sequential processing, or reduction.
