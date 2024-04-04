const std = @import("std");

const time = @import("time.zig");
const recompute = @import("aggr/recompute.zig");

const Example = struct {
    aaa: usize,
    bbb: usize,
};

fn passTypeValue(ex: Example, comptime field_name: []const u8) @TypeOf(@field(ex, field_name)) {
    const result = @field(ex, field_name);
    return result;
}

fn inputFn(input: usize) void {
    std.debug.print("\n\t\t{d}\n", .{input});
}

pub fn main() !void {
    const ex = Example{
        .aaa = 1,
        .bbb = 2,
    };
    inputFn(passTypeValue(ex, "aaa"));
    inputFn(passTypeValue(ex, "bbb"));
}
