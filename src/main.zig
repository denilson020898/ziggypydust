const std = @import("std");

const time = @import("time.zig");
const recompute = @import("aggr/recompute.zig");

pub fn main() !void {
    // for (@typeInfo(recompute.RecomputeFields).Struct.fields) |f| {
    //     std.debug.print("{any}", .{f});
    // }

    inline for (std.meta.fields(recompute.RecomputeFields)) |field_info| {
        std.debug.print("{s}\n", .{field_info.name});
    }
}
