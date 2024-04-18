const std = @import("std");
const py = @import("pydust");

const logic = @import("aggr_logic.zig");
const costing = @import("aggr/costing.zig");

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

pub fn process_lock_costing_selector(args: struct {
    buf: py.PyObject,
    itemsize: usize,
    shape_x: usize,
    shape_y: usize,
    stride_x: usize,
    stride_y: usize,
    partner_dict: py.PyDict,
}) !py.PyString {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var out = std.ArrayList(u8).init(allocator);
    defer out.deinit();

    try logic.loopCosting(
        &out,
        &args.buf,
        args.itemsize,
        args.shape_x,
        args.shape_y,
        args.stride_x,
        args.stride_y,
        &args.partner_dict,
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

    // var result = try py.PyList.

    return result;
}

// // A simple fibonacci implementation.
// pub fn nth_fibonacci_iterative(args: struct { n: u64 }) u64 {
//     if (args.n < 2) return args.n;
//     var f0: u64 = 0;
//     var f1: u64 = 1;
//     var fnth: u64 = f0 + f1;
//     for (2..args.n) |_| {
//         f0 = f1;
//         f1 = fnth;
//         fnth = f0 + f1;
//     }
//     return fnth;
// }
//
// // A simple recursive fibonacci implementation.
// pub fn nth_fibonacci_recursive(args: struct { n: u64, f0: u64 = 0, f1: u64 = 1 }) u64 {
//     if (args.n == 0) return args.f0;
//     if (args.n == 1) return args.f1;
//     return nth_fibonacci_recursive(.{
//         .n = args.n - 1,
//         .f0 = args.f1,
//         .f1 = args.f0 + args.f1,
//     });
// }
//
// // Leveraging the `@call` function to enforce a tail call.
// pub fn nth_fibonacci_recursive_tail(args: struct { n: u64 }) u64 {
//     return fibonacci_recursive_tail(args.n, 0, 1);
// }
// fn fibonacci_recursive_tail(n: u64, f0: u64, f1: u64) u64 {
//     if (n == 0) return f0;
//     if (n == 1) return f1;
//     return @call(.always_tail, fibonacci_recursive_tail, .{ n - 1, f1, f0 + f1 });
// }
//
// // Exposing it through a Python class.
// pub const Fibonacci = py.class(struct {
//     pub const __doc__ = "A class that computes the Fibonacci numbers.";
//
//     const Self = @This();
//
//     first_n: u64,
//
//     pub fn __init__(self: *Self, args: struct { first_n: u64 }) void {
//         self.first_n = args.first_n;
//     }
//
//     // Get an iterator over the first `self.first_n` Fibonacci numbers.
//     pub fn __iter__(self: *const Self) !*FibonacciIterator {
//         return try py.init(FibonacciIterator, .{ .i = 0, .ith = 0, .next = 1, .stop = self.first_n });
//     }
// });
//
// pub const FibonacciIterator = py.class(struct {
//     pub const __doc__ = "An iterator that computes the Fibonacci numbers.";
//
//     const Self = @This();
//
//     i: u64,
//     ith: u64,
//     next: u64,
//     stop: u64,
//
//     pub fn __init__(self: *Self, args: struct { i: u64, ith: u64, next: u64, stop: u64 }) void {
//         self.i = args.i;
//         self.ith = args.ith;
//         self.next = args.next;
//         self.stop = args.stop;
//     }
//
//     pub fn __next__(self: *Self) !?u64 {
//         // Stop iteration when we reach `self.stop`.
//         if (self.i == self.stop) return null;
//         defer self.i += 1;
//
//         const result = self.ith;
//         self.ith = self.next;
//         self.next = result + self.ith;
//         return result;
//     }
// });
//
comptime {
    py.rootmodule(@This());
}
//
// // The rest of this file is test code.
//
// // `poetry run pytest` will run zig tests along with python tests.
// // `zig build test` still works (within `poetry shell`) and runs just zig tests.
//
// const testing = std.testing;
//
// test "fibonacci iterative" {
//     py.initialize();
//     defer py.finalize();
//
//     try testing.expectEqual(@as(u64, 34), nth_fibonacci_iterative(.{ .n = 9 }));
// }
//
// test "fibonacci recursive" {
//     py.initialize();
//     defer py.finalize();
//
//     try testing.expectEqual(@as(u64, 34), nth_fibonacci_recursive(.{ .n = 9 }));
// }
//
// test "fibonacci recursive tail" {
//     py.initialize();
//     defer py.finalize();
//
//     try testing.expectEqual(@as(u64, 34), nth_fibonacci_recursive_tail(.{ .n = 9 }));
// }
