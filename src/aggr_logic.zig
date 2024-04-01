const std = @import("std");
const py = @import("pydust");

const time = @import("time.zig");

const costing = @import("aggr/costing.zig");

fn stackBufferSize() comptime_int {
    return 64;
}

/// caller must free the returned bytes manually
fn concat(allocator: std.mem.Allocator, a: []const u8, b: []const u8) std.mem.Allocator.Error![]u8 {
    const result = try allocator.alloc(u8, a.len + b.len);
    // std.mem.copy(u8, result, a);
    // std.mem.copy(u8, result[a.len..], b);
    @memcpy(result, a);
    @memcpy(result[a.len..], b);
    return result;
}

fn selfConcat(a: []const u8, b: []const u8, out: []u8) void {
    std.debug.assert(out.len >= a.len + b.len);
    std.mem.copy(u8, out, a);
    std.mem.copy(u8, out[a.len..], b);
}

pub fn loopCosting(
    buf: *const py.PyObject,
    itemsize: usize,
    shape_x: usize,
    shape_y: usize,
    stride_x: usize,
    stride_y: usize,
    partner_dict: *const py.PyDict,
) !u64 {
    std.debug.assert(itemsize > 0);
    std.debug.assert(shape_x > 0);
    std.debug.assert(shape_y > 0);
    std.debug.assert(stride_x > 0);
    std.debug.assert(stride_y > 0);

    std.debug.print("\t\tlen partner_dict {}\n", .{partner_dict.length()});

    var result: u64 = 0;

    const view = try buf.getBuffer(py.PyBuffer.Flags.ND);
    defer view.release();

    std.debug.print("\t##{any}\n", .{view});

    const len_x = shape_x * shape_y * itemsize;
    const arr_ptr = view.asSlice(u8)[0..len_x];

    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena.deinit();
    // const allocator = arena.allocator();

    for (0..shape_x) |x| {
        const lower_offset_x = x * stride_x;
        const upper_offset_x = lower_offset_x + stride_x;
        const row = arr_ptr[lower_offset_x..upper_offset_x];

        // var costing_number: []const u8 = undefined;
        // var latest_costing_number_ts: []const u8 = undefined;
        // var mitra_code_genesis: []const u8 = undefined;
        // var stt_booked_date: []const u8 = undefined;
        // var stt_pod_date: []const u8 = undefined;
        // var etl_date: []const u8 = undefined;

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

            // var values: []u8 = "";
            var idx: usize = 0;
            while (idx < per_row.len) : (idx += 4) {
                const new = per_row[idx .. idx + 1];
                if (!std.mem.eql(u8, new, "\x00")) {
                    // values = try concat(allocator, values, new);

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

        // const costing_number_sent: []const u8 = std.mem.span(sentinel[]);

        const cs = try costing.Costing.lock(
            &costing_number,
            &latest_costing_number_ts,
            &mitra_code_genesis,
            &stt_booked_date,
            &stt_pod_date,
            &etl_date,
            partner_dict,
        );

        // _ = cs;
        std.debug.print("{}\n", .{cs});

        // const lock_query = f"UPDATE costing_selector SET costing_number_ts='{costing_number_ts}', schedule_cost='{schedule_cost}', odoo_partner_id={odoo_partner_id}, odoo_partner_user_id={odoo_partner_user_id or 'NULL'}, bill_schedule_date='{bill_schedule_date}', is_delayed={schedule_delay} WHERE costing_number='{costing_number}';\n";
        // const lock_query = "UPDATE costing_selector SET costing_number_ts='{costing_number_ts}', schedule_cost='{schedule_cost}', odoo_partner_id={odoo_partner_id}, odoo_partner_user_id={odoo_partner_user_id or 'NULL'}, bill_schedule_date='{bill_schedule_date}', is_delayed={schedule_delay} WHERE costing_number='{costing_number}';\n";

        result += 1;
    }

    return result;
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
