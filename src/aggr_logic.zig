const std = @import("std");
const py = @import("pydust");

const time = @import("time.zig");

const LockCostingFields = struct {
    costing_number: []const u8,
    latest_costing_number_ts: []const u8,
    mitra_code_genesis: []const u8,
    stt_booked_date: []const u8,
    stt_pod_date: []const u8,
    etl_date: []const u8,

    pub fn format(
        lcf: LockCostingFields,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.writeAll("LockCostingFields{\n");

        _ = try writer.print("\tcosting_number: {s},\n", .{lcf.costing_number});
        _ = try writer.print("\tlatest_costing_number_ts: {s},\n", .{lcf.latest_costing_number_ts});
        _ = try writer.print("\tmitra_code_genesis: {s},\n", .{lcf.mitra_code_genesis});
        _ = try writer.print("\tstt_booked_date: {s},\n", .{lcf.stt_booked_date});
        _ = try writer.print("\tstt_pod_date: {s},\n", .{lcf.stt_pod_date});
        _ = try writer.print("\tetl_date: {s},\n", .{lcf.etl_date});

        try writer.writeAll("}\n");
    }
};

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

fn stackBufferSize() comptime_int {
    return 64;
}

fn castSentinelToSlice(input_slice: []const u8) []const u8 {
    return std.mem.span(@as([*:0]const u8, @ptrCast(input_slice)));
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

        const per_row_lock = LockCostingFields{
            .costing_number = castSentinelToSlice(&costing_number),
            .latest_costing_number_ts = castSentinelToSlice(&latest_costing_number_ts),
            .mitra_code_genesis = castSentinelToSlice(&mitra_code_genesis),
            .stt_booked_date = castSentinelToSlice(&stt_booked_date),
            .stt_pod_date = castSentinelToSlice(&stt_pod_date),
            .etl_date = castSentinelToSlice(&etl_date),
        };

        var data = try getPartnerData(partner_dict, per_row_lock.mitra_code_genesis);

        // _ = per_row_lock;
        // _ = data;

        std.debug.print("{}{}\n", .{ per_row_lock, data });

        // const lock_query = f"UPDATE costing_selector SET costing_number_ts='{costing_number_ts}', schedule_cost='{schedule_cost}', odoo_partner_id={odoo_partner_id}, odoo_partner_user_id={odoo_partner_user_id or 'NULL'}, bill_schedule_date='{bill_schedule_date}', is_delayed={schedule_delay} WHERE costing_number='{costing_number}';\n";
        // const lock_query = "UPDATE costing_selector SET costing_number_ts='{costing_number_ts}', schedule_cost='{schedule_cost}', odoo_partner_id={odoo_partner_id}, odoo_partner_user_id={odoo_partner_user_id or 'NULL'}, bill_schedule_date='{bill_schedule_date}', is_delayed={schedule_delay} WHERE costing_number='{costing_number}';\n";

        result += 1;
    }

    return result;
}

pub const PartnerData = struct {
    schedule_cost: []const u8,
    odoo_partner_id: u32,
    odoo_partner_user_id: ?u32,

    pub fn format(
        pd: PartnerData,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.writeAll("PartnerData{\n");

        _ = try writer.print("\tschedule_cost: {s},\n", .{pd.schedule_cost});
        _ = try writer.print("\todoo_partner_id: {},\n", .{pd.odoo_partner_id});
        _ = try writer.print("\todoo_partner_user_id: {any},\n", .{pd.odoo_partner_user_id});

        try writer.writeAll("}\n");
    }
};

pub const PartnerDataError = error{
    MitraNotFound,
};

// pub const ScheduleError = error{
// };

pub fn getPartnerData(partner_dict: *const py.PyDict, mitra_code: []const u8) !PartnerData {
    const py_sc = try py.PyString.create("schedule_cost");
    const py_pi = try py.PyString.create("partner_id");
    const py_pui = try py.PyString.create("partner_user_id");
    const py_mitra_code = try py.PyString.create(mitra_code);

    defer py_sc.decref();
    defer py_pi.decref();
    defer py_pui.decref();
    defer py_mitra_code.decref();

    const contains = try partner_dict.contains(py_mitra_code);
    if (!contains) {
        std.debug.print("ERROR: '{s}' is not found in partner dict.", .{mitra_code});
        return PartnerDataError.MitraNotFound;
    }

    const current_mitra = try partner_dict.getItem(py.PyDict, py_mitra_code);

    var schedule_cost: []const u8 = undefined;
    var partner_id: u32 = undefined;
    var partner_user_id: ?u32 = undefined;

    if (current_mitra) |value| {
        const sc_unchecked = try value.getItem(py.PyString, py_sc);
        if (sc_unchecked) |sc| {
            schedule_cost = try sc.asSlice();
        }

        const pi_unchecked = try value.getItem(py.PyLong, py_pi);
        if (pi_unchecked) |pi| {
            partner_id = try pi.as(u32);
        }

        const pyobj_partner_user_id = try value.getItem(py.PyObject, py_pui);
        if (!py.is_none(pyobj_partner_user_id)) {
            if (try value.getItem(py.PyLong, py_pui)) |pui| {
                partner_user_id = try pui.as(u32);
            }
        } else {
            partner_user_id = null;
        }
    }

    return .{
        .schedule_cost = schedule_cost,
        .odoo_partner_id = partner_id,
        .odoo_partner_user_id = partner_user_id,
    };
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
