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
        var etl_date: []const u8 = undefined;

        var j: usize = 0;
        while (j < c.length()) : (j += 1) {
            const parsed = try c.getItem([]const u8, j);
            switch (j) {
                0 => costing_number = parsed,
                1 => latest_costing_number_ts = parsed,
                2 => mitra_code_genesis = parsed,
                3 => stt_booked_date = parsed,
                4 => stt_pod_date = parsed,
                5 => etl_date = parsed,
                else => unreachable,
            }
        }
        const cs = try costing.Costing.lock(
            costing_number,
            latest_costing_number_ts,
            mitra_code_genesis,
            stt_booked_date,
            stt_pod_date,
            etl_date,
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

pub fn loopCosting(
    out: *std.ArrayList(u8),
    buf: *const py.PyObject,
    itemsize: usize,
    shape_x: usize,
    shape_y: usize,
    stride_x: usize,
    stride_y: usize,
    partner_dict: *const py.PyDict,
) !void {
    std.debug.assert(itemsize > 0);
    std.debug.assert(shape_x > 0);
    std.debug.assert(shape_y > 0);
    std.debug.assert(stride_x > 0);
    std.debug.assert(stride_y > 0);

    const view = try buf.getBuffer(py.PyBuffer.Flags.ND);
    defer view.release();

    const len_x = shape_x * shape_y * itemsize;
    const arr_ptr = view.asSlice(u8)[0..len_x];

    for (0..shape_x) |x| {
        const lower_offset_x = x * stride_x;
        const upper_offset_x = lower_offset_x + stride_x;
        const row = arr_ptr[lower_offset_x..upper_offset_x];

        var costing_number: [stackBufferSize()]u8 = undefined;
        var latest_costing_number_ts: [stackBufferSize()]u8 = undefined;
        var mitra_code_genesis: [stackBufferSize()]u8 = undefined;
        var stt_booked_date: [stackBufferSize()]u8 = undefined;
        var stt_pod_date: [stackBufferSize()]u8 = undefined;
        var etl_date: [stackBufferSize()]u8 = undefined;

        for (0..shape_y) |y| {
            const lower_offset_y = y * stride_y;
            const upper_offset_y = lower_offset_y + stride_y;

            const per_row = row[lower_offset_y..upper_offset_y];

            var slice_value: [256]u8 = undefined;
            var slice_end_idx: usize = 0;

            var idx: usize = 0;
            while (idx < per_row.len) : (idx += 4) {
                const new = per_row[idx .. idx + 1];
                if (!std.mem.eql(u8, new, "\x00")) {
                    const current_slice = slice_value[0..slice_end_idx];
                    slice_end_idx += 1;
                    selfConcat(current_slice, new, &slice_value);
                }
            }

            const current_slice = slice_value[0..slice_end_idx];
            selfConcat(current_slice, "\x00", &slice_value);
            const sentinel: [*:0]const u8 = @ptrCast(&slice_value);
            // const values: []const u8 = std.mem.span(sentinel);

            switch (y) {
                0 => @memcpy(&costing_number, sentinel),
                1 => @memcpy(&latest_costing_number_ts, sentinel),
                2 => @memcpy(&mitra_code_genesis, sentinel),
                3 => @memcpy(&stt_booked_date, sentinel),
                4 => @memcpy(&stt_pod_date, sentinel),
                5 => @memcpy(&etl_date, sentinel),
                else => unreachable,
            }
        }

        const cs = try costing.Costing.lock(
            &costing_number,
            &latest_costing_number_ts,
            &mitra_code_genesis,
            &stt_booked_date,
            &stt_pod_date,
            &etl_date,
            partner_dict,
            true,
            20,
        );

        try out.writer().print("{}\n", .{cs});
    }
}

test "time lib" {
    const init_new = time.DateTime.init(2024, 3, 3, 3, 3, 3);

    std.debug.print("\n\n\tnow wib is {iso}\n", .{init_new});
    std.debug.print("\n\t\t\t new value {D} {Do} {DD}", .{ init_new, init_new, init_new });
}

// const zigstr = @import("zigstr");

// const PartnerDataInput = struct {
//     mitra: PartnerDataMitra,
// };

// const PartnerDataMitra = struct {
//     display_name: []const u8,
//     partner_id: usize,
//     partner_user_id: ?usize,
//     display_name: []const u8,
// };

// test "test create dict inline" {
//     py.initialize();
//     defer py.finalize();

//     // partner_dict = {
//     //     'CJT-1585': {
//     //         'display_name': 'CJT-1585',
//     //         'partner_id': 71934,
//     //         'partner_user_id': None,
//     //         'schedule_cost': 'monthly'
//     //     },
//     //     'CON10850': {
//     //         'display_name': 'CON10850',
//     //         'partner_id': 71948,
//     //         'partner_user_id': None,
//     //         'schedule_cost': 'monthly'
//     //     },
//     // }

//     const zig_data_mitra = .{
//         .display_name = "AAA",
//         .partner_id = 71934,
//         // .partner_user_id = null,
//         .schedule_cost = "monthly",
//     };

//     const zig_data_input = .{
//         .mitra = zig_data_mitra,
//     };

//     const my_dict = try py.PyDict.create(zig_data_input);
//     defer my_dict.decref();

//     // var data = try getPartnerData(&my_dict, "AAA");
//     std.debug.print("\n\n\t\t{}\n", .{my_dict});
//     // std.debug.print("\n\n\t\t{}\n", .{data});

//     try std.testing.expect(true);
// }
