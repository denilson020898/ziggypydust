const std = @import("std");
const py = @import("pydust");

pub fn process() void {
    std.debug.print("BROOO\n", .{});
}

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

        // try writer.writeAll("\timages: [\n");
        // for (lock_costing_fields.images) |image| _ = try writer.print("\t\t{s},\n", .{image});
        // try writer.writeAll("\t],\n");
        //
        try writer.writeAll("}\n");
    }
};

fn concat(allocator: std.mem.Allocator, a: []const u8, b: []const u8) ![]u8 {
    const result = try allocator.alloc(u8, a.len + b.len);
    std.mem.copy(u8, result, a);
    std.mem.copy(u8, result[a.len..], b);
    return result;
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

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    for (0..shape_x) |x| {
        const lower_offset_x = x * stride_x;
        const upper_offset_x = lower_offset_x + stride_x;
        const row = arr_ptr[lower_offset_x..upper_offset_x];

        var costing_number: []const u8 = undefined;
        var latest_costing_number_ts: []const u8 = undefined;
        var mitra_code_genesis: []const u8 = undefined;
        var stt_booked_date: []const u8 = undefined;
        var stt_pod_date: []const u8 = undefined;
        var etl_date: []const u8 = undefined;

        for (0..shape_y) |y| {
            const lower_offset_y = y * stride_y;
            const upper_offset_y = lower_offset_y + stride_y;

            const per_row = row[lower_offset_y..upper_offset_y];

            // var row_elem: []u8 = "";

            // var buffer: [2]u8 = undefined;
            // var fba = std.heap.FixedBufferAllocator.init(&buffer);
            // const allocator = fba.allocator();

            var values: []u8 = "";
            var idx: usize = 0;
            var end_idx: usize = 1;
            while (idx < per_row.len) : (idx += 4) {
                end_idx += 1;
                // value = value[0..last_idx] ++ per_row[idx .. idx + 1];

                const new = per_row[idx .. idx + 1];
                if (!std.mem.eql(u8, new, "\x00")) {
                    values = try concat(allocator, values, new);
                }
            }

            // const value = per_row[0..1] ++ per_row[4..5];
            // std.debug.print("\t {s}\n", .{values});

            // for (values) |value| {
            //     std.debug.print("\t 0x{x} is {u} {d}\n", .{ value, value, value });
            // }

            // for (row_elem) |value| {
            //     std.debug.print("\t 0x{x} is {u} {d}\n", .{ value, value, value });
            // }

            // break;

            switch (y) {
                0 => costing_number = values,
                1 => latest_costing_number_ts = values,
                2 => mitra_code_genesis = values,
                3 => stt_booked_date = values,
                4 => stt_pod_date = values,
                5 => etl_date = values,
                else => unreachable,
            }

            // std.debug.print("row{}, col{}: {s}\n", .{ x, y, values });
        }

        const per_row_lock = LockCostingFields{
            .costing_number = costing_number,
            .latest_costing_number_ts = latest_costing_number_ts,
            .mitra_code_genesis = mitra_code_genesis,
            .stt_booked_date = stt_booked_date,
            .stt_pod_date = stt_pod_date,
            .etl_date = etl_date,
        };

        var data = try getPartnerData(partner_dict, mitra_code_genesis);

        _ = per_row_lock;
        _ = data;
        // var data = try getPartnerData(partner_dict, "CONS104");

        // const pystr = "CONS104";
        // std.debug.print("zig str\t\t\t {s} | {} | {any}\n", .{
        //     pystr,
        //     @TypeOf(pystr),
        //     pystr,
        // });
        // std.debug.print("py numpy\t\t {s} | {} | {any}\n", .{
        //     per_row_lock.mitra_code_genesis,
        //     @TypeOf(&per_row_lock.mitra_code_genesis),
        //     &per_row_lock.mitra_code_genesis,
        // });

        // std.debug.print("{any}\n", .{per_row_lock});
        // std.debug.print("mitra_code_genesis {s}: {any}\n", .{ mitra_code_genesis, data });
        // const first_char_slice = per_row_lock.costing_number;
        // for (first_char_slice) |value| {
        //     std.debug.print("\t 0x{x} is {u} {d}\n", .{ value, value, value });
        // }
        //
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
