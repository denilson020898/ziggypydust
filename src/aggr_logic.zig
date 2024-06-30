// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const std = @import("std");
const py = @import("pydust");

const time = @import("time.zig");
const costing = @import("aggr/costing.zig");
const recompute = @import("aggr/recompute.zig");
const proforma = @import("aggr/proforma.zig");

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

pub fn loopSttList(
    out: *std.ArrayList(u8),
    list: *const py.PyList,
    partner_dict: *const py.PyDict,
    stt_schedule: *const proforma.SttSchedule,
) !void {
    var i: isize = 0;
    while (i < list.length()) : (i += 1) {
        const c = try list.getItem(py.PyTuple, i);

        var sel_proforma = proforma.SelProforma{};
        inline for (std.meta.fields(@TypeOf(sel_proforma)), 0..) |field_info, idx| {
            const parsed = if (field_info.type == time.DateTime) parsed: {
                const result_str = try c.getItem([]const u8, idx);
                const result = try time.parseOdooDate(result_str);
                break :parsed result;
            } else parsed: {
                const result = try c.getItem(field_info.type, idx);
                break :parsed result;
            };
            @field(sel_proforma, field_info.name) = parsed;
        }
        const locked = try proforma.Proforma.lock(
            &sel_proforma,
            partner_dict,
            stt_schedule,
        );
        try out.writer().print("{any}\n", .{locked});
    }
}

pub fn recomputeSoQuery(
    out_airflow: *std.ArrayList(u8),
    out_odoo: *std.ArrayList(u8),
    list: *const py.PyList,
) !void {
    var i: isize = 0;
    while (i < list.length()) : (i += 1) {
        const c = try list.getItem(py.PyTuple, i);

        var recom = proforma.RecomputeSttDetail{};
        inline for (std.meta.fields(@TypeOf(recom)), 0..) |field_info, idx| {
            const parsed = if (@typeInfo(field_info.type) == .Optional) parsed: {
                const pyobj = try c.getItem(py.PyObject, idx);
                const result = if (py.is_none(pyobj)) null else try c.getItem(field_info.type, idx);
                break :parsed result;
            } else parsed: {
                const result = try c.getItem(field_info.type, idx);
                break :parsed result;
            };
            @field(recom, field_info.name) = parsed;
        }

        try out_airflow.writer().print("{airflow}\n", .{recom});
        try out_odoo.writer().print("{odoo}\n", .{recom});
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
                break :parsed result;
            };
            @field(recom, field_info.name) = parsed;
        }
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
