const std = @import("std");
const py = @import("pydust");

const logic = @import("aggr_logic.zig");
const SttSchedule = @import("aggr/proforma.zig").SttSchedule;

pub fn process_lock_costing_selector_list(args: struct {
    list: py.PyList,
    partner_dict: py.PyDict,
    schedule_day: u64,
}) !py.PyString {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var out = std.ArrayList(u8).init(allocator);
    defer out.deinit();

    try logic.loopCostingList(
        &out,
        &args.list,
        &args.partner_dict,
        args.schedule_day,
    );

    const py_str = try py.PyString.create(out.items);
    return py_str;
}

pub fn update_proforma_schedule_list(args: struct {
    list: py.PyList,
    partner_dict: py.PyDict,
    schedule_daily_hair: u64,
    schedule_daily_minute: u64,
    schedule_weekly_day: u64,
    schedule_biweekly_first_date: u64,
    schedule_biweekly_second_date: u64,
    schedule_monthly: u64,
}) !py.PyString {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var out = std.ArrayList(u8).init(allocator);
    defer out.deinit();

    const stt_schedule = SttSchedule{
        .schedule_daily_hair = args.schedule_daily_hair,
        .schedule_daily_minute = args.schedule_daily_minute,
        .schedule_weekly_day = args.schedule_weekly_day,
        .schedule_biweekly_first_date = args.schedule_biweekly_first_date,
        .schedule_biweekly_second_date = args.schedule_biweekly_second_date,
        .schedule_monthly = args.schedule_monthly,
    };

    try logic.loopSttList(
        &out,
        &args.list,
        &args.partner_dict,
        &stt_schedule,
    );

    const py_str = try py.PyString.create(out.items);
    return py_str;
}

pub fn generate_recompute_queries(args: struct {
    list: py.PyList,
}) !py.PyList {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var out_airflow = std.ArrayList(u8).init(allocator);
    defer out_airflow.deinit();

    var out_odoo = std.ArrayList(u8).init(allocator);
    defer out_odoo.deinit();

    try logic.recomputeQuery(
        &out_airflow,
        &out_odoo,
        &args.list,
    );

    const py_str_airflow = try py.PyString.create(out_airflow.items);
    const py_str_odoo = try py.PyString.create(out_odoo.items);

    var result = try py.PyList.new(2);
    try result.setItem(0, py_str_airflow);
    try result.setItem(1, py_str_odoo);

    return result;
}

comptime {
    py.rootmodule(@This());
}
