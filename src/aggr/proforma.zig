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

pub const SttSchedule = struct {
    schedule_monthly: u64,
    schedule_biweekly_second_date: u64,
    schedule_biweekly_first_date: u64,
    schedule_weekly_day: u64,
    schedule_daily_minute: u64,
    schedule_daily_hair: u64,
};

const LockProforma = struct {
    schedule_so: []const u8,
    odoo_partner_id: u64,
    odoo_partner_user_id: ?u64,
    schedule_date: time.DateTime,

    const Self = @This();
    pub fn new(
        schedule_so: []const u8,
        odoo_partner_id: u64,
        odoo_partner_user_id: ?u64,
        sel_proforma: *const SelProforma,
        stt_schedule: *const SttSchedule,
    ) !Self {
        _ = stt_schedule;
        var schedule_date: time.DateTime = undefined;

        const now = time.DateTime.now().addHours(7); // Asia/Jakarta
        const now_ts = time.DateTime.toUnix(now);
        _ = now_ts;

        if (std.mem.eql(u8, schedule_so, "monthly")) {
            unreachable;
        } else if (std.mem.eql(u8, schedule_so, "biweekly")) {
            unreachable;
        } else if (std.mem.eql(u8, schedule_so, "weekly")) {
            unreachable;
            // var assumed_pod_date = sel_proforma.modified_at.addDays(1);
            // // while (assumed_pod_date.weekday != time.WeekDay.Mon) : (assumed_pod_date = assumed_pod_date.addDays(1)) {}
            // // same logic
            // var target_day: time.WeekDay = undefined;
            // if (stt_schedule.schedule_weekly_day == 0) {
            //     target_day = time.WeekDay.Mon;
            // } else if (stt_schedule.schedule_weekly_day == 1) {
            //     target_day = time.WeekDay.Tue;
            // } else if (stt_schedule.schedule_weekly_day == 2) {
            //     target_day = time.WeekDay.Wed;
            // } else if (stt_schedule.schedule_weekly_day == 3) {
            //     target_day = time.WeekDay.Thu;
            // } else if (stt_schedule.schedule_weekly_day == 4) {
            //     target_day = time.WeekDay.Fri;
            // } else if (stt_schedule.schedule_weekly_day == 5) {
            //     target_day = time.WeekDay.Sat;
            // } else if (stt_schedule.schedule_weekly_day == 6) {
            //     target_day = time.WeekDay.Sun;
            // }
            //
            // while (assumed_pod_date.weekday != target_day) {
            //     assumed_pod_date = assumed_pod_date.addDays(1);
            //     std.debug.print("increment\n", .{});
            // }
            // assumed_pod_date.hours = 0;
            // assumed_pod_date.minutes = 0;
            // assumed_pod_date.seconds = 1;
            // schedule_date = assumed_pod_date;
        } else if (std.mem.eql(u8, schedule_so, "daily")) {
            var assumed_pod_date = sel_proforma.modified_at;
            // schedule_date = time.DateTime.init(
            //     assumed_pod_date.years,
            //     assumed_pod_date.months,
            //     assumed_pod_date.days,
            //     0,
            //     0,
            //     1,
            // );
            schedule_date = assumed_pod_date.addDays(1);
            // const schedule_ts = time.DateTime.toUnix(schedule_date);
            //
            // if (schedule_ts < now_ts) {
            //     const start_of_tmrw = time.DateTime.init(
            //         schedule_date.years,
            //         schedule_date.months,
            //         schedule_date.days,
            //         0,
            //         0,
            //         0,
            //     );
            //     // this "time" library
            //     // represents the months and days with 1 less value
            //     schedule_date = start_of_tmrw.addDays(1).addSecs(1);
            // }
        } else {
            unreachable;
        }

        return .{
            .schedule_so = schedule_so,
            .odoo_partner_id = odoo_partner_id,
            .odoo_partner_user_id = odoo_partner_user_id,
            .schedule_date = schedule_date,
        };
    }
};

pub const SelProforma = struct {
    stt_id: []const u8 = undefined,
    latest_stt_ts: []const u8 = undefined,
    stt_date: time.DateTime = undefined,
    modified_at: time.DateTime = undefined,
    mother_account: []const u8 = undefined,
    platform_type: []const u8 = undefined,
};

pub const Proforma = struct {
    sel_proforma: *const SelProforma,
    lock_proforma: LockProforma,

    const Self = @This();

    pub fn lock(
        sel_proforma: *const SelProforma,
        partner_dict: *const py.PyDict,
        stt_schedule: *const SttSchedule,
    ) !Self {
        const contains = try partner_dict.contains(sel_proforma.mother_account);
        if (!contains) {
            return error.MitraNotFound;
        }
        const cur_partner = try partner_dict.getItem(py.PyList, sel_proforma.mother_account);

        const odoo_partner_id = try cur_partner.?.getItem(u64, 0);
        const schedule_so = try cur_partner.?.getItem([]const u8, 1);
        const odoo_partner_user_id = try cur_partner.?.getItem(?u64, 3);

        return .{
            .sel_proforma = sel_proforma,
            .lock_proforma = try LockProforma.new(
                schedule_so,
                odoo_partner_id,
                odoo_partner_user_id,
                sel_proforma,
                stt_schedule,
            ),
        };
    }

    fn calculateSchedule(stt_schedule: *const SttSchedule) !time.DateTime {
        _ = stt_schedule;
        return time.DateTime.now();
    }

    pub fn format(
        self: Self,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        // UPDATE stt_selector SET
        //     mother_account = '{mother_account}',
        //     schedule_so = '{schedule_so}',
        //     odoo_partner_id = {res_partner_id},
        //     odoo_partner_user_id = {partner_user_id},
        //     platform_type = '{platform_type}',
        //     proforma_stt_ts = '{stt_ts}',
        //     stt_pod_date = '{modified_at}',
        //     proforma_schedule_date = '{schedule_date}'
        // WHERE stt_id = '{stt_sel}';

        try writer.writeAll("UPDATE stt_selector SET ");
        _ = try writer.print("mother_account='{s}',", .{self.sel_proforma.stt_id});
        _ = try writer.print("stt_date='{YYYY-MM-DD} {HH}:{mm}:{ss}',", .{
            self.sel_proforma.stt_date,
            self.sel_proforma.stt_date,
            self.sel_proforma.stt_date,
            self.sel_proforma.stt_date,
        });
        _ = try writer.print("modified_at='{YYYY-MM-DD} {HH}:{mm}:{ss}',", .{
            self.sel_proforma.modified_at,
            self.sel_proforma.modified_at,
            self.sel_proforma.modified_at,
            self.sel_proforma.modified_at,
        });
        _ = try writer.print("schedule_so='{s}',", .{self.lock_proforma.schedule_so});
        _ = try writer.print("proforma_schedule_date='{YYYY-MM-DD} {HH}:{mm}:{ss}',", .{
            self.lock_proforma.schedule_date,
            self.lock_proforma.schedule_date,
            self.lock_proforma.schedule_date,
            self.lock_proforma.schedule_date,
        });
        // // _ = try writer.print("odoo_partner_id='{s}',", .{self.odoo_partner_id});
        // // _ = try writer.print("odoo_partner_user_id='{s}',", .{self.odoo_partner_user_id});
        // _ = try writer.print("platform_type='{s}',", .{self.platform_type});
        // _ = try writer.print("proforma_stt_ts='{s}',", .{self.latest_stt_ts});
        // // _ = try writer.print("stt_pod_date='{s}',", .{self.stt_pod_date});
        // // _ = try writer.print("proforma_schedule_date='{s}' ", .{self.proforma_schedule_date});
        // _ = try writer.print("WHERE stt_id = '{s}';", .{self.stt_id});
    }
};
