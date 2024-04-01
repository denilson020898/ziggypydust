const std = @import("std");
const py = @import("pydust");

pub const PartnerData = struct {
    schedule_cost: []const u8,
    odoo_partner_id: u32,
    odoo_partner_user_id: ?u32,
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
