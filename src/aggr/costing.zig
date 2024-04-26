const std = @import("std");
const py = @import("pydust");

const pd = @import("partner_data.zig");
const time = @import("../time.zig");

const LockCosting = struct {
    costing_number: []const u8,
    latest_costing_number_ts: []const u8,
    mitra_code_genesis: []const u8,
    stt_booked_date: []const u8,
    stt_pod_date: []const u8,
    etl_date: []const u8,
};

pub const Costing = struct {
    lock_costing: LockCosting,
    partner_data: pd.PartnerData,
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
        etl_date: []const u8,
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
            etl_date,
            cast_sentinel,
        );

        // it's important to use result.lock_costing.mitra_code_genesis
        // because it has been casted to the proper sentinel slice length
        result.partner_data = try pd.getPartnerData(partner_dict, result.lock_costing.mitra_code_genesis);

        try result.calculateSchedule(schedule_day);

        return result;
    }

    fn create(
        costing_number: []const u8,
        latest_costing_number_ts: []const u8,
        mitra_code_genesis: []const u8,
        stt_booked_date: []const u8,
        stt_pod_date: []const u8,
        etl_date: []const u8,
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
                .etl_date = castSentinelToSlice(etl_date),
            };
        } else {
            lock_costing = LockCosting{
                .costing_number = costing_number,
                .latest_costing_number_ts = latest_costing_number_ts,
                .mitra_code_genesis = mitra_code_genesis,
                .stt_booked_date = stt_booked_date,
                .stt_pod_date = stt_pod_date,
                .etl_date = etl_date,
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
        // self.lock_costing
        const stt_pod_date = try parseOdooDate(self.lock_costing.stt_pod_date);
        var schedule_date = calculateScheduleDate(&stt_pod_date, schedule_day);
        const etl_date = try parseOdooDate(self.lock_costing.etl_date);
        const a = time.DateTime.toUnix(schedule_date);
        const b = time.DateTime.toUnix(etl_date);

        if (a < b) {
            schedule_date = calculateScheduleDate(&etl_date, schedule_day);
            self.is_delay = true;
        }

        self.schedule_date = schedule_date;
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

    fn parseOdooDate(input: []const u8) !time.DateTime {
        var date_time_it = std.mem.splitScalar(u8, input, ' ');
        var is_time: bool = false;

        var year: u16 = undefined;
        var month: u16 = undefined;
        var day: u16 = undefined;
        var hr: u16 = undefined;
        var min: u16 = undefined;
        var sec: u16 = undefined;

        // this can't fail, the format will always be like
        // input "2024-02-03 01:11:59"
        while (date_time_it.next()) |date_time| {
            if (!is_time) {
                var date_s = std.mem.splitScalar(u8, date_time, '-');
                year = try std.fmt.parseInt(u16, date_s.next().?, 10);
                month = try std.fmt.parseInt(u16, date_s.next().?, 10);
                day = try std.fmt.parseInt(u16, date_s.next().?, 10);
                is_time = true;
            } else {
                var time_s = std.mem.splitScalar(u8, date_time, ':');
                hr = try std.fmt.parseInt(u16, time_s.next().?, 10);
                min = try std.fmt.parseInt(u16, time_s.next().?, 10);
                sec = try std.fmt.parseInt(u16, time_s.next().?, 10);
            }
        }

        return time.DateTime.init(
            year,
            month - 1,
            day - 1,
            hr,
            min,
            sec,
        );
    }

    pub fn format(
        c: Costing,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = try writer.print("UPDATE costing_selector SET costing_number_ts='{s}',schedule_cost='{s}',odoo_partner_id={any},odoo_partner_user_id={any},bill_schedule_date='{YYYY-MM-DD} {HH}:{mm}:{ss}',is_delayed={any} WHERE costing_number='{s}';", .{
            c.lock_costing.latest_costing_number_ts,
            c.partner_data.schedule_cost,
            c.partner_data.odoo_partner_id,
            c.partner_data.odoo_partner_user_id,

            c.schedule_date,
            c.schedule_date,
            c.schedule_date,
            c.schedule_date,

            c.is_delay,
            c.lock_costing.costing_number,
        });
    }
};
