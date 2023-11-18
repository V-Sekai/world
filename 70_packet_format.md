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

A full RigidBody structure on the server consists of position, orientation, linear_velocity and angular_velocity. Rotation is stored as x/y is an octahedral normal storing axis, while z is the rotation. Converting from this to quaternion is extremely efficient.

struct Entity {
    TimeOffsetPacket time_offset_packet;
    Vector<DataPacket> data_packets;
}
```

The size of each `TimeOffsetPacket` is `8 bytes` and the size of each `DataPacket` is `12 bytes`. Therefore, the size of each `Entity` would be `(1 * 8) + (4 * 12) = 56 bytes`.

## Scenario

- **Total Players (n)**: 100 players.
- **Total Bones per Player (b)**: 54 bones.

## Snapshot Size

The total snapshot size would be the sum of the sizes of all the `Entity` structs for all players and their bones.

- Player's `Entity`: `n * 56 bytes = 100 * 56 bytes = 5600 bytes`.
- Player's Bones: `n * b * 56 bytes = 100 * 54 * 56 bytes = 302400 bytes`.

So, the total snapshot size would be `5600 bytes + 302400 bytes = 308000 bytes`, or approximately `300.78 KB`.

This calculation assumes that there are no other data included in the snapshot and that the `Entity` struct does not have any padding or alignment issues. In a real-world scenario, the actual snapshot size might be larger due to additional game state information, network overhead, etc.

By using octahedral compression for orientation, we can significantly reduce the snapshot size. However, the exact amount of savings depends on the specific details of the game state and the effectiveness of the compression algorithm.

## References

1. [Serialization Strategies](https://gafferongames.com/post/serialization_strategies/)
2. [Networked Physics in Virtual Reality](https://www.youtube.com/watch?v=sx4IIQL0x7c)
3. [Godot Engine Proposal](https://github.com/godotengine/godot-proposals/issues/3375)
