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
    ) !Self {
        var result = create(
            costing_number,
            latest_costing_number_ts,
            mitra_code_genesis,
            stt_booked_date,
            stt_pod_date,
            etl_date,
        );

        // it's important to use result.lock_costing.mitra_code_genesis
        // because it has been casted to the proper sentinel slice length
        result.partner_data = try pd.getPartnerData(partner_dict, result.lock_costing.mitra_code_genesis);

        try result.calculateSchedule();

        return result;
    }

    fn create(
        costing_number: []const u8,
        latest_costing_number_ts: []const u8,
        mitra_code_genesis: []const u8,
        stt_booked_date: []const u8,
        stt_pod_date: []const u8,
        etl_date: []const u8,
    ) Self {
        const lock_costing = LockCosting{
            .costing_number = castSentinelToSlice(costing_number),
            .latest_costing_number_ts = castSentinelToSlice(latest_costing_number_ts),
            .mitra_code_genesis = castSentinelToSlice(mitra_code_genesis),
            .stt_booked_date = castSentinelToSlice(stt_booked_date),
            .stt_pod_date = castSentinelToSlice(stt_pod_date),
            .etl_date = castSentinelToSlice(etl_date),
        };

        return .{
            .lock_costing = lock_costing,
            .partner_data = undefined,
            .schedule_date = undefined,
        };
    }

    fn calculateSchedule(self: *Self) !void {
        // self.lock_costing
        const stt_pod_date = try parseOdooDate(self.lock_costing.stt_pod_date);
        var schedule_date = calculateScheduleDate(&stt_pod_date);
        const etl_date = try parseOdooDate(self.lock_costing.etl_date);
        const a = time.DateTime.toUnix(schedule_date);
        const b = time.DateTime.toUnix(etl_date);
        if (a < b) {
            schedule_date = schedule_date.addDays(5);
            self.is_delay = true;
        }

        self.schedule_date = schedule_date;
    }

    fn calculateScheduleDate(pod_date: *const time.DateTime) time.DateTime {
        var year: u16 = pod_date.years;
        var month: u16 = pod_date.months;
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
        result = result.addMonths(1).addDays(18).addSecs(1);
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
        try writer.writeAll("Costing{\n");

        _ = try writer.print("\t== LockCosting ==\n", .{});
        _ = try writer.print("\tcosting_number: {s},\n", .{c.lock_costing.costing_number});
        _ = try writer.print("\tlatest_costing_number_ts: {s},\n", .{c.lock_costing.latest_costing_number_ts});
        _ = try writer.print("\tmitra_code_genesis: {s},\n", .{c.lock_costing.mitra_code_genesis});
        _ = try writer.print("\tstt_booked_date: {s},\n", .{c.lock_costing.stt_booked_date});
        _ = try writer.print("\tstt_pod_date: {s},\n", .{c.lock_costing.stt_pod_date});
        _ = try writer.print("\tetl_date: {s},\n", .{c.lock_costing.etl_date});
        _ = try writer.print("\t== PartnerData ==\n", .{});
        _ = try writer.print("\tschedule_cost: {s},\n", .{c.partner_data.schedule_cost});
        _ = try writer.print("\todoo_partner_id: {},\n", .{c.partner_data.odoo_partner_id});
        _ = try writer.print("\todoo_partner_user_id: {any},\n", .{c.partner_data.odoo_partner_user_id});
        _ = try writer.print("\t== Scheduling ==\n", .{});
        _ = try writer.print("\tschedule_date: {YYYY-MM-DD} {HH}:{mm}:{ss},\n", .{ c.schedule_date, c.schedule_date, c.schedule_date, c.schedule_date });
        _ = try writer.print("\tis_delay: {},\n", .{c.is_delay});

        try writer.writeAll("}\n");
    }
};
