const std = @import("std");
const expect = std.testing.expect;

pub const GlobalState = struct {
    allocator: std.mem.Allocator,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var state = GlobalState{ .allocator = allocator };

    const greeting = try print_name(&state, "Federico Vitale");
    defer allocator.free(greeting);

    std.debug.print("{s}", .{greeting});
}

pub fn print_name(state: *GlobalState, name: []const u8) ![]const u8 {
    return std.fmt.allocPrint(state.allocator, "Hello {s}!\n", .{name});
}

test "if statement" {
    const a = true;
    var x: u16 = 0;

    if (a) {
        x += 1;
    } else {
        x += 2;
    }

    try expect(x == 1);
}

test "if statement expr" {
    const a = true;
    var x: u16 = 0;
    x += if (a) 1 else 2;

    try expect(x == 1);
}

test "while" {
    var i: u8 = 2;
    while (i < 5) {
        i *= 2;
    }

    try expect(i == 8);
}

test "while with index" {
    var i: u8 = 0;
    var n: u8 = 2;
    while (n < 5) : (i += 1) {
        n *= 2;
    }

    try expect(n == 8);
    try expect(i == 2);
}

test "for loop" {
    const string = "hello";

    for (string, 0..) |c, i| {
        try expect(c == "hello"[i]);
    }
}

const AllocationError = error{OutOfMemory};
const FileOpenError = error{ OutOfMemory, AccessDenied, FileNotFound };

test "coerce error from a subset to a superset" {
    const err: FileOpenError = AllocationError.OutOfMemory;
    try expect(err == FileOpenError.OutOfMemory);
}

fn fail() error{Oops}!void {
    return error.Oops;
}

test "returning an error" {
    fail() catch |err| {
        try expect(err == error.Oops);
    };
}

// structs

const Vec = struct {
    x: f32,
    y: f32,
    fn eq(self: *Vec, other: Vec) bool {
        return self.x == other.x and self.y == other.y;
    }
};

fn sumVec(a: Vec, b: Vec) Vec {
    return Vec{ .x = a.x + b.x, .y = a.y + b.y };
}

test "sumVec" {
    const a = Vec{ .x = 1.0, .y = 2.0 };
    const b = Vec{ .x = 3.0, .y = 4.0 };
    var c = sumVec(a, b);
    try expect(c.eq(Vec{ .x = 4.0, .y = 6.0 }));
}
