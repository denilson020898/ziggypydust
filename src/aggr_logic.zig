const std = @import("std");
const py = @import("pydust");

const time = @import("time.zig");
const costing = @import("aggr/costing.zig");
const recompute = @import("aggr/recompute.zig");

pub fn loopCostingList(
    out: *std.ArrayList(u8),
    list: *const py.PyList,
    partner_dict: *const py.PyDict,
    schedule_day: u64,
) !void {
    var i: isize = 0;
    while (i < list.length()) : (i += 1) {
        const c = try list.getItem(py.PyTuple, i);

        var costing_number: []const u8 = undefined;
        var latest_costing_number_ts: []const u8 = undefined;
        var mitra_code_genesis: []const u8 = undefined;
        var stt_booked_date: []const u8 = undefined;
        var stt_pod_date: []const u8 = undefined;
        var ts_date: []const u8 = undefined;

        var j: usize = 0;
        while (j < c.length()) : (j += 1) {
            const parsed = try c.getItem([]const u8, j);
            switch (j) {
                0 => costing_number = parsed,
                1 => latest_costing_number_ts = parsed,
                2 => mitra_code_genesis = parsed,
                3 => stt_booked_date = parsed,
                4 => stt_pod_date = parsed,
                5 => ts_date = parsed,
                else => unreachable,
            }
        }
        const cs = try costing.Costing.lock(
            costing_number,
            latest_costing_number_ts,
            mitra_code_genesis,
            stt_booked_date,
            stt_pod_date,
            ts_date,
            partner_dict,
            false,
            schedule_day,
        );
        try out.writer().print("{s}\n", .{cs});
    }
}

pub fn recomputeQuery(
    out_airflow: *std.ArrayList(u8),
    out_odoo: *std.ArrayList(u8),
    list: *const py.PyList,
) !void {
    var i: isize = 0;
    while (i < list.length()) : (i += 1) {
        const c = try list.getItem(py.PyTuple, i);

        var recom = recompute.RecomputeFields{};
        inline for (std.meta.fields(recompute.RecomputeFields), 0..) |field_info, idx| {
            const parsed = if (@typeInfo(field_info.type) == .Optional) parsed: {
                const pyobj = try c.getItem(py.PyObject, idx);
                const result = if (py.is_none(pyobj)) null else try c.getItem(field_info.type, idx);
                break :parsed result;
            } else parsed: {
                const result = try c.getItem(field_info.type, idx);
                // std.debug.print("##\t\t{} {s} {any}\n", .{ idx, field_info.name, result });
                break :parsed result;
            };
            // std.debug.print("idx {} -> {s} {any} {any}\n", .{ idx, field_info.name, field_info.type, parsed });

            @field(recom, field_info.name) = parsed;
        }
        // std.debug.print("{}\n", .{recom});
        try out_airflow.writer().print("{airflow}\n", .{recom});
        try out_odoo.writer().print("{odoo}\n", .{recom});
    }
}

fn stackBufferSize() comptime_int {
    return 64;
}

fn selfConcat(a: []const u8, b: []const u8, out: []u8) void {
    std.debug.assert(out.len >= a.len + b.len);
    std.mem.copy(u8, out, a);
    std.mem.copy(u8, out[a.len..], b);
}

/// caller must free the returned bytes manually
fn concat(allocator: std.mem.Allocator, a: []const u8, b: []const u8) std.mem.Allocator.Error![]u8 {
    const result = try allocator.alloc(u8, a.len + b.len);
    std.mem.copy(u8, result, a);
    std.mem.copy(u8, result[a.len..], b);
    return result;
}

test "time lib" {
    const init_new = time.DateTime.init(2024, 3, 3, 3, 3, 3);

    std.debug.print("\n\n\tnow wib is {iso}\n", .{init_new});
    std.debug.print("\n\t\t\t new value {D} {Do} {DD}", .{ init_new, init_new, init_new });
}
