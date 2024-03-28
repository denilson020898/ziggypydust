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

const LockFieldName = enum {
    costing_number,
    latest_costing_number_ts,
    mitra_code_genesis,
    stt_booked_date,
    stt_pod_date,
    etl_date,
};

pub fn process_lock_costing_selector(args: struct {
    buf: py.PyObject,
    itemsize: usize,
    shape_x: usize,
    shape_y: usize,
    stride_x: usize,
    stride_y: usize,
}) !u64 {
    std.debug.assert(args.itemsize > 0);
    std.debug.assert(args.shape_x > 0);
    std.debug.assert(args.shape_y > 0);
    std.debug.assert(args.stride_x > 0);
    std.debug.assert(args.stride_y > 0);

    var result: u64 = 0;

    const view = try args.buf.getBuffer(py.PyBuffer.Flags.ND);
    defer view.release();

    const len_x = args.shape_x * args.shape_y * args.itemsize;
    const arr_ptr = view.asSlice(u8)[0..len_x];
    // std.debug.print("arr_ptr: {any}\n", .{arr_ptr});

    for (0..args.shape_x) |x| {
        const lower_offset_x = x * args.stride_x;
        const upper_offset_x = lower_offset_x + args.stride_x;
        // std.debug.print("\t{} {}\n", .{ lower_offset_x, upper_offset_x });
        const row = arr_ptr[lower_offset_x..upper_offset_x];

        // std.debug.print("\t\t{any} {any} {any} {any}\n", .{ @TypeOf(row), @TypeOf(row.ptr), @TypeOf(row.len), row });
        for (0..args.shape_y) |y| {
            const lower_offset_y = y * args.stride_y;
            const upper_offset_y = lower_offset_y + args.stride_y;
            // std.debug.print("\t\t\t{} {}\n", .{ lower_offset_y, upper_offset_y });
            const elem_y = row[lower_offset_y..upper_offset_y];
            _ = elem_y;
            // std.debug.print("row{}, col{}: {s}\n", .{ x, y, elem_y });
            result += 1;
        }
    }

    return result;
}

const KeyVal = struct {
    key: usize,
};

const KeyVal2 = struct {
    // 'SUB17023', 72010, 'monthly', 'SUB17023'
    py.PyString,
    py.PyLong,
    py.PyString,
    py.PyString,
};

// pub fn variadic(args: struct { hello: py.PyString, args: py.Args, kwargs: py.Kwargs }) !py.PyString {
pub fn variadic(
    args: struct {
        hello: py.PyString,
        input_dict: py.PyDict,
        // input_list: py.PyList,
    },
) !py.PyString {
    // logic.process();
    // return py.PyString.createFmt(
    //     "Hellos {s} with {} varargs and {?} kwargs",
    //     .{ try args.hello.asSlice(), args.args.len, args.kwargs.get("kw") },
    // );

    const hello = try args.hello.asSlice();
    std.debug.print("\n\thello {s}\n", .{hello});

    // std.debug.print("\tinput_list.len {}\n", .{args.input_list.length()});
    // const first_index = try args.input_list.getItem(py.PyList, 0);
    // // std.debug.print("\tfirst_index {any}\n", .{first_index});
    // const first_inner_list = try first_index.getItem(py.PyLong, 0);
    // const first_inner_long = try first_inner_list.as(isize);
    // std.debug.print("\t\tfirst_inner_long {any}\n", .{first_inner_long});
    // const second_inner_list = try first_index.getItem(py.PyLong, 1);
    // const second_inner_long = try second_inner_list.as(isize);
    // std.debug.print("\t\tsecond_inner_long {any}\n", .{second_inner_long});

    std.debug.print("\tinput_dict {}\n", .{args.input_dict});
    std.debug.print("\tinput_dict does contain {}\n", .{try args.input_dict.contains(py.PyString.create("CJT-1585"))});
    std.debug.print("\tinput_dict does not contain {}\n", .{try args.input_dict.contains(py.PyString.create("SONSON"))});

    const cjtn = try args.input_dict.getItem(py.PyDict, py.PyString.create("MISSING"));
    if (cjtn) |value| {
        std.debug.print("\tcjtn {any}\n", .{value});
    } else {
        std.debug.print("\tcjtn does not exist\n", .{});
    }

    const cjt = try args.input_dict.getItem(py.PyDict, py.PyString.create("CJT-1585"));

    if (cjt) |value| {
        const schedule_cost_unchecked = try value.getItem(py.PyString, py.PyString.create("schedule_cost"));
        if (schedule_cost_unchecked) |schedule_cost| {
            std.debug.print("\t\tschedule_cost {s}\n", .{try schedule_cost.asSlice()});
        }

        if (try value.getItem(py.PyLong, py.PyString.create("partner_id"))) |partner_id| {
            std.debug.print("\t\tpartner_id {}\n", .{try partner_id.as(isize)});
        }

        const partner_user_id = try value.getItem(py.PyLong, py.PyString.create("partner_user_id"));
        std.debug.print("\t\tparter_user_id {any}\n", .{partner_user_id});
        // if (try value.getItem(py.PyLong, py.PyString.create("partner_user_id"))) |partner_user_id| {
        // std.debug.print("\t\tparter_user_id {}\n", .{partner_user_id});

        // std.debug.print("\t\tis_none {}\n", .{py.is_none(partner_user_id)});

        // if (!py.is_none(partner_user_id)) {
        //     std.debug.print("\t\tpartner_user_id {}\n", .{try partner_user_id.as(isize)});
        // } else {
        //     std.debug.print("\t\tpartner_user_id is none\n", .{});
        // }
        // }
    } else {
        std.debug.print("\tcjtn does not exist\n", .{});
    }

    // std.debug.print("\tinput_dict$ {}\n", .{try args.input_dict.as(KeyVal)});

    return py.PyString.create("HAHA");
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
