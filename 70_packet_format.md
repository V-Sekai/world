# Variable bit rate encoding

The strategy we want to use is called variable bit rate encoding to optimize the use of bandwidth.

In the context of our game, this strategy can be applied to reduce the amount of data that needs to be sent over the network for each snapshot. Here's how it could work with your `TimeOffsetPacket` and `DataPacket` structures:

1. **Keyframe Omission**: Instead of sending a full update (a keyframe) for every single frame, you only send keyframes at certain intervals. In between these keyframes, you send smaller updates (delta frames) that describe how the game state has changed since the last keyframe. This is where the `frame_within_metablock` and `frame_offset` fields come into play. They allow you to specify which keyframe a particular delta frame is relative to.

2. **Interpolation**: On the receiving end, the game client uses the data from the keyframes and delta frames to interpolate the game state for the frames in between. This means that even though you're sending less data, the client can still produce a smooth animation. The `x_offset`, `y_offset`, and `z_offset` fields in the `DataPacket` structure are used for this purpose. They provide the information needed to calculate the position of an entity at any given frame.

3. **Variable Bit Rate Encoding**: The `time_bit_width`, `x_bit_width`, `y_bit_width`, and `z_bit_width` fields in the `TimeOffsetPacket` structure allow you to use different amounts of bits for different types of data. For example, if the x, y, and z positions of an entity don't change much from one frame to the next, you might choose to use fewer bits to represent these values. This can help to further reduce the size of your snapshots.

4. **Octahedral Compression**: The rotation of the rigid bodies is stored as an octahedral normal, which is a very efficient way to represent 3D rotations. This can significantly reduce the amount of data needed to represent the orientation of each rigid body.

## Entity

Given the `Entity` struct:

```cpp
struct TimeOffsetPacket {
    uint16_t frame_within_metablock; // Bits 0-15
    uint8_t time_bit_width;          // Bits 16-19
    uint8_t x_bit_width;             // Bits 20-23
    uint8_t y_bit_width;             // Bits 24-27
    uint8_t z_bit_width;             // Bits 28-31
    uint32_t byte_offset_to_first_packet; // Bits 0-23 of high word
    uint8_t amount_of_packets_that_follow; // Bits 24-31 of high word
};

struct DataPacket {
    uint16_t base_x_value; // bits 0-15
    uint16_t base_y_value; // bits 16-31
    uint16_t base_z_value; // bits 32-47
    // The following fields are bit-compressed
    uint16_t frame_offset; // [Time bit width] (unsigned)
    int16_t x_offset;      // [X bit width] (signed)
    int16_t y_offset;      // [Y bit width] (signed)
    int16_t z_offset;      // [Z bit width] (signed)
};
```

1. `TimeOffsetPacket`
1. A full RigidBody structure on the server consists of position, orientation, linear_velocity and angular_velocity.
1. Rotation is stored as x/y is an octahedral normal storing axis, while z is the rotation. Converting from this to quaternion is extremely efficient.

## Scenario

Let's define the following constants:

- **Total Players (TOTAL_PLAYERS)**: 100 players.
- **Total Data Packets per Player (TOTAL_DATA_PACKETS)**: 54 data packets.

## Snapshot Size

The total snapshot size would be the sum of the sizes of all the `Entity` structs for all players and their data packets.

- Player's `Entity`: `TOTAL_PLAYERS * DATAPACKET_BYTES`.
- Player's Data Packets: `TOTAL_PLAYERS * TOTAL_DATA_PACKETS * DATAPACKET_BYTES`.

This calculation assumes that there are no other data included in the snapshot and that the `Entity` struct does not have any padding or alignment issues. In a real-world scenario, the actual snapshot size might be larger due to additional game state information, network overhead, etc.

By using octahedral compression for orientation, we can significantly reduce the snapshot size. However, the exact amount of savings depends on the specific details of the game state and the effectiveness of the compression algorithm.

## References

1. [Serialization Strategies](https://gafferongames.com/post/serialization_strategies/)
2. [Networked Physics in Virtual Reality](https://www.youtube.com/watch?v=sx4IIQL0x7c)
3. [Godot Engine Proposal](https://github.com/godotengine/godot-proposals/issues/3375)
