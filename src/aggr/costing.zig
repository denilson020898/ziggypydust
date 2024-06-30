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

const time = @import("../time.zig");

const PartnerData = struct {
    schedule_cost: []const u8,
    odoo_partner_id: u32,
    odoo_partner_user_id: ?u32,
};

const PartnerDataError = error{
    MitraNotFound,
};

fn getPartnerData(partner_dict: *const py.PyDict, mitra_code: []const u8) !PartnerData {
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

const LockCosting = struct {
    costing_number: []const u8,
    latest_costing_number_ts: []const u8,
    mitra_code_genesis: []const u8,
    stt_booked_date: []const u8,
    stt_pod_date: []const u8,
    ts_date: []const u8,
};

pub const Costing = struct {
    lock_costing: LockCosting,
    partner_data: PartnerData,
    schedule_date: time.DateTime,
    is_delay: bool = false,

    const Self = @This();

    fn castSentinelToSlice(input_slice: []const u8) []const u8 {
        return std.mem.span(@as([*:0]const u8, @ptrCast(input_slice)));
    }

    pub fn lock(
        costing_number: []const u8,
        latest_costing_number_ts: []const u8,
        mitra_code_genesis: []const u8,
        stt_booked_date: []const u8,
        stt_pod_date: []const u8,
        ts_date: []const u8,
        partner_dict: *const py.PyDict,
        cast_sentinel: bool,
        schedule_day: u64,
    ) !Self {
        var result = create(
            costing_number,
            latest_costing_number_ts,
            mitra_code_genesis,
            stt_booked_date,
            stt_pod_date,
            ts_date,
            cast_sentinel,
        );

        // it's important to use result.lock_costing.mitra_code_genesis
        // because it has been casted to the proper sentinel slice length
        result.partner_data = try getPartnerData(partner_dict, result.lock_costing.mitra_code_genesis);

        try result.calculateSchedule(schedule_day);

        return result;
    }

    fn create(
        costing_number: []const u8,
        latest_costing_number_ts: []const u8,
        mitra_code_genesis: []const u8,
        stt_booked_date: []const u8,
        stt_pod_date: []const u8,
        ts_date: []const u8,
        cast_sentinel: bool,
    ) Self {
        var lock_costing: LockCosting = undefined;

        if (cast_sentinel) {
            lock_costing = LockCosting{
                .costing_number = castSentinelToSlice(costing_number),
                .latest_costing_number_ts = castSentinelToSlice(latest_costing_number_ts),
                .mitra_code_genesis = castSentinelToSlice(mitra_code_genesis),
                .stt_booked_date = castSentinelToSlice(stt_booked_date),
                .stt_pod_date = castSentinelToSlice(stt_pod_date),
                .ts_date = castSentinelToSlice(ts_date),
            };
        } else {
            lock_costing = LockCosting{
                .costing_number = costing_number,
                .latest_costing_number_ts = latest_costing_number_ts,
                .mitra_code_genesis = mitra_code_genesis,
                .stt_booked_date = stt_booked_date,
                .stt_pod_date = stt_pod_date,
                .ts_date = ts_date,
            };
        }

        return .{
            .lock_costing = lock_costing,
            .partner_data = undefined,
            .schedule_date = undefined,
        };
    }

    fn calculateSchedule(
        self: *Self,
        schedule_day: u64,
    ) !void {
        const stt_pod_date = try time.parseOdooDate(self.lock_costing.stt_pod_date);
        var pod_schedule_date = calculateScheduleDate(&stt_pod_date, schedule_day);

        const ts_date = try time.parseOdooDate(self.lock_costing.ts_date);
        var ts_schedule_date = calculateScheduleDate(&ts_date, schedule_day);

        var this_month = time.DateTime.now();
        this_month.days = @as(u8, @intCast(schedule_day - 1));
        this_month.hours = 0;
        this_month.minutes = 0;
        this_month.seconds = 1;

        // std.debug.print("\nself: {s}\n", .{self.lock_costing.costing_number});
        // std.debug.print("pod_schedule_date : {YYYY-MM-DD} {HH}:{mm}:{ss}\n", .{
        //     pod_schedule_date,
        //     pod_schedule_date,
        //     pod_schedule_date,
        //     pod_schedule_date,
        // });
        //
        // std.debug.print("ts_schedule_date : {YYYY-MM-DD} {HH}:{mm}:{ss}\n", .{
        //     ts_schedule_date,
        //     ts_schedule_date,
        //     ts_schedule_date,
        //     ts_schedule_date,
        // });
        //
        // std.debug.print("this_month : {YYYY-MM-DD} {HH}:{mm}:{ss}\n", .{
        //     this_month,
        //     this_month,
        //     this_month,
        //     this_month,
        // });

        const pod = time.DateTime.toUnix(pod_schedule_date);
        const ts = time.DateTime.toUnix(ts_schedule_date);
        const tm = time.DateTime.toUnix(this_month);

        if (pod >= tm or ts >= tm) {
            if (ts > pod) {
                self.schedule_date = ts_schedule_date;
            } else {
                self.schedule_date = pod_schedule_date;
            }
            self.is_delay = false;
        } else {
            self.schedule_date = this_month.addMonths(1);
            self.is_delay = true;
        }

        // if (s_ts < t_ts) {
        //     schedule_date = this_month;
        //     self.is_delay = true;
        // }

        // std.debug.print("second: {YYYY-MM-DD} {HH}:{mm}:{ss}\n\n", .{
        //     schedule_date,
        //     schedule_date,
        //     schedule_date,
        //     schedule_date,
        // });

    }

    fn calculateScheduleDate(
        base_date: *const time.DateTime,
        schedule_day: u64,
    ) time.DateTime {
        var year: u16 = base_date.years;
        var month: u16 = base_date.months;
        var day: u16 = 1;
        var hr: u16 = 0;
        var min: u16 = 0;
        var sec: u16 = 0;

        var result = time.DateTime.init(
            year,
            month,
            day,
            hr,
            min,
            sec,
        );

        const target_date = schedule_day - 2;

        result = result.addMonths(1).addDays(target_date).addSecs(1);
        return result;
    }

    pub fn format(
        c: Costing,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.writeAll("UPDATE costing_selector SET ");
        _ = try writer.print("costing_number_ts='{s}',", .{c.lock_costing.latest_costing_number_ts});
        _ = try writer.print("schedule_cost='{s}',", .{c.partner_data.schedule_cost});
        _ = try writer.print("odoo_partner_id={any},", .{c.partner_data.odoo_partner_id});
        _ = try writer.print("odoo_partner_user_id={any},", .{c.partner_data.odoo_partner_user_id});
        _ = try writer.print("bill_schedule_date='{YYYY-MM-DD} {HH}:{mm}:{ss}',", .{
            c.schedule_date,
            c.schedule_date,
            c.schedule_date,
            c.schedule_date,
        });
        _ = try writer.print("is_delayed={any} ", .{c.is_delay});
        _ = try writer.print("WHERE costing_number='{s}';", .{c.lock_costing.costing_number});
    }
};
