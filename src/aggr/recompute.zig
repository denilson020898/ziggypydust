const std = @import("std");

pub const RecomputeFields = struct {
    origin: ?[]const u8 = undefined,
    destination: ?[]const u8 = undefined,
    product: ?[]const u8 = undefined,
    pickup_fee: ?f32 = undefined,
    flight_cost: ?f32 = undefined,
    bucket_file_version: ?[]const u8 = undefined,
    awb_number: ?[]const u8 = undefined,
    tuc_number: ?[]const u8 = undefined,
    stt_booked_date: ?[]const u8 = undefined,
    stt_pod_date: ?[]const u8 = undefined,
    gross_weight: ?f32 = undefined,
    volume_weight: ?f32 = undefined,
    chargeable_weight: ?f32 = undefined,
    client_code: ?[]const u8 = undefined,
    client_name: ?[]const u8 = undefined,
    client_category: ?[]const u8 = undefined,
    route_type: ?[]const u8 = undefined,
    lag_route_origin: ?[]const u8 = undefined,
    lag_route_destination: ?[]const u8 = undefined,
    publish_rate_cost: ?f32 = undefined,
    stt_total_amount: ?f32 = undefined,
    insurance_commission_to_lp: ?f32 = undefined,
    insurance_cost: ?f32 = undefined,
    agent_commision: ?f32 = undefined,
    corporate_discount: ?f32 = undefined,
    woodpacking_fee: ?f32 = undefined,
    pickup_fee_kvp: ?f32 = undefined,
    forward_origin_cost: ?f32 = undefined,
    pcu_fee: ?f32 = undefined,
    outbound_fee: ?f32 = undefined,
    ra_outgoing: ?f32 = undefined,
    wh_outgoing: ?f32 = undefined,
    wh_incoming: ?f32 = undefined,
    truck_cost: ?f32 = undefined,
    train_cost: ?f32 = undefined,
    sea_freight_cost: ?f32 = undefined,
    inbound_fee: ?f32 = undefined,
    delivery_fee_kvp: ?f32 = undefined,
    delivery_fee_mitra: ?f32 = undefined,
    forward_destination_cost_mitra: ?f32 = undefined,
    forward_destination_cost_vendor: ?f32 = undefined,
    cod_commission: ?f32 = undefined,
    lag_route: ?[]const u8 = undefined,
    lag_moda: ?[]const u8 = undefined,
    partner_type: ?[]const u8 = undefined,
    mitra_code_genesis: ?[]const u8 = undefined,
    poscode_on_going_inv_mitra: ?[]const u8 = undefined,
    etl_date: ?[]const u8 = undefined,
    handling_cost: ?f32 = undefined,
    other_cost: ?f32 = undefined,
    bonus_dtpol: ?f32 = undefined,
    costing_number_ts: []const u8 = undefined,
    route_rank: u32 = undefined,

    const Self = @This();

    fn optOrNull(writer: anytype, input: *const RecomputeFields, comptime field_name: []const u8) !void {
        const field_value = @field(input, field_name);
        switch (@TypeOf(field_value)) {
            ?[]const u8 => {
                if (field_value) |content| {

                    // NOTE: replace single quote
                    // 'POS LION PARCEL KH. AHMAD SYA'YANI'
                    // to
                    // 'POS LION PARCEL KH. AHMAD SYA''YANI'
                    //
                    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
                    defer _ = gpa.deinit();
                    const allocator = gpa.allocator();
                    const size = std.mem.replacementSize(u8, content, "'", "''");
                    var output = try allocator.alloc(u8, size);
                    defer allocator.free(output);
                    _ = std.mem.replace(u8, content, "'", "''", output);

                    _ = try writer.print("{s}='{s}',", .{ field_name, output });
                } else {
                    _ = try writer.print("{s}=null,", .{field_name});
                }
            },
            ?f32 => {
                if (field_value) |content| {
                    _ = try writer.print("{s}={d:.2},", .{ field_name, content });
                } else {
                    _ = try writer.print("{s}=null,", .{field_name});
                }
            },
            ?u32 => {
                if (field_value) |content| {
                    _ = try writer.print("{s}={d},", .{ field_name, content });
                } else {
                    _ = try writer.print("{s}=null,", .{field_name});
                }
            },
            else => unreachable,
        }
    }

    pub fn format(
        self: Self,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = options;
        if (std.mem.eql(u8, fmt, "odoo")) {
            try self.formatOdoo(writer);
        } else if (std.mem.eql(u8, fmt, "airflow")) {
            try self.formatAirflow(writer);
        }
    }

    fn formatOdoo(c: *const Self, writer: anytype) !void {
        try writer.writeAll("UPDATE stt_middleware_costing SET ");

        try optOrNull(writer, c, "origin");
        try optOrNull(writer, c, "destination");
        try writer.writeAll("write_date=NOW() AT TIME ZONE 'Asia/Jakarta',");
        try optOrNull(writer, c, "product");
        try optOrNull(writer, c, "pickup_fee");
        try optOrNull(writer, c, "flight_cost");

        try optOrNull(writer, c, "bucket_file_version");
        try optOrNull(writer, c, "awb_number");
        try optOrNull(writer, c, "tuc_number");
        try optOrNull(writer, c, "stt_booked_date");
        try optOrNull(writer, c, "stt_pod_date");

        try optOrNull(writer, c, "gross_weight");
        try optOrNull(writer, c, "volume_weight");
        try optOrNull(writer, c, "chargeable_weight");

        try optOrNull(writer, c, "client_code");
        try optOrNull(writer, c, "client_name");
        try optOrNull(writer, c, "client_category");
        try optOrNull(writer, c, "route_type");
        try optOrNull(writer, c, "lag_route_origin");
        try optOrNull(writer, c, "lag_route_destination");

        try optOrNull(writer, c, "publish_rate_cost");
        try optOrNull(writer, c, "stt_total_amount");
        try optOrNull(writer, c, "insurance_commission_to_lp");
        try optOrNull(writer, c, "insurance_cost");
        try optOrNull(writer, c, "agent_commision");
        try optOrNull(writer, c, "corporate_discount");
        try optOrNull(writer, c, "woodpacking_fee");
        try optOrNull(writer, c, "pickup_fee_kvp");
        try optOrNull(writer, c, "forward_origin_cost");
        try optOrNull(writer, c, "pcu_fee");
        try optOrNull(writer, c, "outbound_fee");
        try optOrNull(writer, c, "ra_outgoing");
        try optOrNull(writer, c, "wh_outgoing");
        try optOrNull(writer, c, "wh_incoming");
        try optOrNull(writer, c, "truck_cost");
        try optOrNull(writer, c, "train_cost");
        try optOrNull(writer, c, "sea_freight_cost");
        try optOrNull(writer, c, "inbound_fee");
        try optOrNull(writer, c, "delivery_fee_kvp");
        try optOrNull(writer, c, "delivery_fee_mitra");

        try optOrNull(writer, c, "forward_destination_cost_mitra");
        try optOrNull(writer, c, "forward_destination_cost_vendor");
        try optOrNull(writer, c, "cod_commission");

        try optOrNull(writer, c, "lag_route");
        try optOrNull(writer, c, "lag_moda");

        try optOrNull(writer, c, "partner_type");
        try optOrNull(writer, c, "mitra_code_genesis");
        try optOrNull(writer, c, "poscode_on_going_inv_mitra");
        try optOrNull(writer, c, "etl_date");
        try optOrNull(writer, c, "handling_cost");
        try optOrNull(writer, c, "other_cost");

        try optOrNull(writer, c, "bonus_dtpol");

        _ = try writer.print("costing_number_ts='{s}',", .{c.costing_number_ts});
        _ = try writer.print("route_rank={} ", .{c.route_rank});
        // try optOrNull(writer, c, "route_rank");

        var cnit = std.mem.splitScalar(u8, c.costing_number_ts, ';');
        _ = cnit.first();
        _ = try writer.print("WHERE costing_number = '{s};{s};{s}';", .{ cnit.next().?, cnit.next().?, cnit.next().? });
    }

    fn formatAirflow(c: *const Self, writer: anytype) !void {
        try writer.writeAll("UPDATE costing_selector x ");
        try writer.writeAll("SET costing_number_ts = y.latest_costing_number_ts ");
        try writer.writeAll("FROM (SELECT costing_number,costing_number_ts,");
        try writer.writeAll("latest_costing_number_ts FROM costing_selector ");
        var cnit = std.mem.splitScalar(u8, c.costing_number_ts, ';');
        _ = cnit.first();
        _ = try writer.print("WHERE costing_number='{s};{s};{s}' FOR UPDATE) y ", .{ cnit.next().?, cnit.next().?, cnit.next().? });
        try writer.writeAll("WHERE x.costing_number=y.costing_number;");
    }
};
