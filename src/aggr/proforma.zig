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
    schedule_daily_hour: u64,
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
        var schedule_date: time.DateTime = undefined;

        const now = time.DateTime.now().addHours(7); // Asia/Jakarta
        const now_ts = time.DateTime.toUnix(now);

        if (std.mem.eql(u8, schedule_so, "monthly")) {
            const day_monthly: u8 = @intCast(stt_schedule.schedule_monthly - 1);
            const book_date = sel_proforma.stt_date;
            const pod_date = sel_proforma.modified_at;

            var schedule_no_pod = book_date.addMonths(1);
            schedule_no_pod.days = day_monthly;
            schedule_no_pod.hours = 0;
            schedule_no_pod.minutes = 0;
            schedule_no_pod.seconds = 1;

            var schedule_stt = pod_date.addMonths(1);
            schedule_stt.days = day_monthly;
            schedule_stt.hours = 0;
            schedule_stt.minutes = 0;
            schedule_stt.seconds = 1;

            const pod_date_ts = time.DateTime.toUnix(pod_date);
            const schedule_no_pod_ts = time.DateTime.toUnix(schedule_no_pod);
            if (pod_date_ts < schedule_no_pod_ts) {
                schedule_stt = schedule_no_pod;
            } else {
                var schedule_pod_catchup = pod_date;
                schedule_pod_catchup.days = day_monthly;
                schedule_pod_catchup.hours = 0;
                schedule_pod_catchup.minutes = 0;
                schedule_pod_catchup.seconds = 1;
                const schedule_pod_catchup_ts = time.DateTime.toUnix(schedule_pod_catchup);
                if (pod_date_ts < schedule_pod_catchup_ts) {
                    schedule_stt = schedule_pod_catchup;
                }
            }

            schedule_date = schedule_stt;
        } else if (std.mem.eql(u8, schedule_so, "biweekly")) {
            const first_date: u8 = @intCast(stt_schedule.schedule_biweekly_first_date - 1);
            const second_date: u8 = @intCast(stt_schedule.schedule_biweekly_second_date - 1);
            const pod_date = sel_proforma.modified_at;

            var schedule_pod_first = pod_date;
            schedule_pod_first.days = first_date;
            schedule_pod_first.hours = 0;
            schedule_pod_first.minutes = 0;
            schedule_pod_first.seconds = 1;

            var schedule_pod_second = pod_date;
            schedule_pod_second.days = second_date;
            schedule_pod_second.hours = 0;
            schedule_pod_second.minutes = 0;
            schedule_pod_second.seconds = 1;

            var schedule_pod_next_first = pod_date.addMonths(1);
            schedule_pod_next_first.days = first_date;
            schedule_pod_next_first.hours = 0;
            schedule_pod_next_first.minutes = 0;
            schedule_pod_next_first.seconds = 1;

            const pod_date_ts = time.DateTime.toUnix(pod_date);
            const schedule_pod_first_ts = time.DateTime.toUnix(schedule_pod_first);
            const schedule_pod_second_ts = time.DateTime.toUnix(schedule_pod_second);
            const schedule_pod_next_first_ts = time.DateTime.toUnix(schedule_pod_next_first);

            schedule_date = schedule_pod_first;
            if (pod_date_ts < schedule_pod_first_ts) {
                schedule_date = schedule_pod_first;
            } else if (pod_date_ts < schedule_pod_second_ts) {
                schedule_date = schedule_pod_second;
            } else if (pod_date_ts < schedule_pod_next_first_ts) {
                schedule_date = schedule_pod_next_first;
            }
        } else if (std.mem.eql(u8, schedule_so, "weekly")) {
            var assumed_pod_date = sel_proforma.modified_at.addDays(1);

            var target_day: time.WeekDay = undefined;
            if (stt_schedule.schedule_weekly_day == 0) {
                target_day = time.WeekDay.Mon;
            } else if (stt_schedule.schedule_weekly_day == 1) {
                target_day = time.WeekDay.Tue;
            } else if (stt_schedule.schedule_weekly_day == 2) {
                target_day = time.WeekDay.Wed;
            } else if (stt_schedule.schedule_weekly_day == 3) {
                target_day = time.WeekDay.Thu;
            } else if (stt_schedule.schedule_weekly_day == 4) {
                target_day = time.WeekDay.Fri;
            } else if (stt_schedule.schedule_weekly_day == 5) {
                target_day = time.WeekDay.Sat;
            } else if (stt_schedule.schedule_weekly_day == 6) {
                target_day = time.WeekDay.Sun;
            }

            while (assumed_pod_date.weekday() != target_day) {
                assumed_pod_date = assumed_pod_date.addDays(1);
            }
            assumed_pod_date.hours = 0;
            assumed_pod_date.minutes = 0;
            assumed_pod_date.seconds = 1;
            schedule_date = assumed_pod_date;
        } else if (std.mem.eql(u8, schedule_so, "daily")) {
            var assumed_pod_date = sel_proforma.modified_at.addDays(1);
            schedule_date = time.DateTime.init(
                assumed_pod_date.years,
                assumed_pod_date.months,
                assumed_pod_date.days,
                0,
                0,
                1,
            );
            const schedule_ts = time.DateTime.toUnix(schedule_date);
            if (schedule_ts < now_ts) {
                const start_of_tmrw = time.DateTime.init(
                    now.years,
                    now.months,
                    now.days,
                    0,
                    0,
                    1,
                );
                schedule_date = start_of_tmrw.addDays(1);
            }
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
