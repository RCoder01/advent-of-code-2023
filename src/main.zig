const std = @import("std");
const root = @import("root.zig");

const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");

fn callDay(day: u8, part: u8, file: *std.fs.File) !i32 {
    switch (day) {
        1 => if (part == 1) {
            return try day1.part1(file);
        } else if (part == 2) {
            return try day1.part2(file);
        } else {
            return error.partOutOfRange;
        },
        2 => if (part == 1) {
            return try day2.part1(file);
        } else if (part == 2) {
            return try day2.part2(file);
        } else {
            return error.partOutOfRange;
        },
        3 => if (part == 1) {
            return try day3.part1(file);
        } else if (part == 2) {
            return try day3.part2(file);
        } else {
            return error.partOutOfRange;
        },
        else => {
            return error.dayOutOfRange;
        },
    }
    unreachable;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var args = try std.process.argsWithAllocator(gpa.allocator());
    defer args.deinit();
    _ = args.next();
    const day = try std.fmt.parseInt(u8, args.next().?, 10);
    const part = try std.fmt.parseInt(u8, args.next().?, 10);
    const filepath = args.next().?;
    var file = try std.fs.cwd().openFile(filepath, .{});
    const result = try callDay(day, part, &file);
    const stdout_writer = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_writer);
    const stdout = bw.writer();
    try stdout.print("{d}", .{result});
    try bw.flush();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
