const std = @import("std");
const py = @import("pydust");

const logic = @import("logic.zig");

// pub fn process_lock_int(args: struct {
//     buf: py.PyObject,
//     itemsize: usize,
//     shape_x: usize,
//     shape_y: usize,
//     stride_x: usize,
//     stride_y: usize,
// }) !i64 {
//     std.debug.assert(args.itemsize > 0);
//     std.debug.assert(args.shape_x > 0);
//     std.debug.assert(args.shape_y > 0);
//     std.debug.assert(args.stride_x > 0);
//     std.debug.assert(args.stride_y > 0);
//
//     const view = try args.buf.getBuffer(py.PyBuffer.Flags.ND);
//     defer view.release();
//
//     std.debug.print("VIEW : {any}\n\n", .{view});
//
//     std.debug.print("shape : {}, {}\n\n", .{ args.shape_x, args.shape_y });
//     const len = args.shape_x * args.shape_y;
//     const arr_ptr = view.asSlice(i64)[0..len];
//     std.debug.print("arr_ptr: {any}\n", .{arr_ptr});
//
//     for (0..args.shape_x) |x| {
//         for (0..args.shape_y) |y| {
//             const offset: usize = args.stride_x * x + args.stride_y * y;
//             std.debug.print("\t{} {} {}\n", .{ x, y, offset });
//         }
//     }
//
//     // var bufferSum: i64 = 0;
//     // for (view.asSlice(i64)) |value| bufferSum += value;
//     // return bufferSum;
//     return 10;
// }

pub fn process_lock_costing_selector(args: struct {
    buf: py.PyObject,
    nbytes: usize,
    itemsize: usize,
    shape_x: usize,
    shape_y: usize,
    stride_x: usize,
    stride_y: usize,
    partner_dict: py.PyDict,
}) !u64 {
    const result = try logic.loopCosting(
        &args.buf,
        args.nbytes,
        args.itemsize,
        args.shape_x,
        args.shape_y,
        args.stride_x,
        args.stride_y,
        &args.partner_dict,
    );
    return result;
}

// const zigstr = @import("zigstr");

// pub fn variadic(args: struct { hello: py.PyString, args: py.Args, kwargs: py.Kwargs }) !py.PyString {
pub fn variadic(
    args: struct {
        hello: py.PyString,
        input_dict: py.PyDict,
        mitra_code: []const u8,
    },
) !py.PyString {
    // const hello = try args.hello.asSlice();
    // std.debug.print("\n\thello {s}\n", .{hello});

    std.debug.print("args.mitra_code {s}\n{any}\n", .{ args.mitra_code, args.mitra_code });
    //
    // var data = try logic.getPartnerData(&args.input_dict, args.mitra_code);
    // std.debug.print("{}\n", .{data});

    // return logic.PartnerDataError.MitraNotFound;
    return py.PyString.create("RET");
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
