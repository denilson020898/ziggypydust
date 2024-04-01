const std = @import("std");

const time = @import("time.zig");

pub fn main() !void {
    const now = time.now();
    std.debug.print("\nnow wib is {ISO}\n", .{now});

    const stt_pod_date = "2024-03-18 07:53:05";
    parseDate(stt_pod_date);
}

fn parseDate(input: []const u8) void {
    std.debug.print("{s}\n", .{input});
    return;
}
