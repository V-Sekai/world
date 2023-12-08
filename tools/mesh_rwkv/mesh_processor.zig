const std = @import("std");
const c = @cImport({
    @cInclude("cgltf.h");
});

pub fn main() !void {
    var options: c.cgltf_options = undefined;
    std.mem.set(u8, &options, 0);

    var data: *c.cgltf_data = undefined;
    const result = c.cgltf_parse_file(&options, "path_to_your_gltf_file.gltf", &data);

    if (result == c.cgltf_result_success) {
        // Successfully loaded the file, you can now access the data.
        // Don't forget to free the data when you're done:
        // c.cgltf_free(data);
    } else {
        std.debug.warn("Failed to load glTF file\n");
    }
}
