const std = @import("std");

const Day = struct {
    part1: *const fn (*std.fs.File) anyerror!isize,
    part2: *const fn (*std.fs.File) anyerror!isize,

    fn create(comptime day: anytype) Day {
        const DayWrapper = struct {
            fn part1(file: *std.fs.File) anyerror!isize {
                return try day.part1(file);
            }

            fn part2(file: *std.fs.File) anyerror!isize {
                return try day.part2(file);
            }
        };

        return .{
            .part1 = DayWrapper.part1,
            .part2 = DayWrapper.part2,
        };
    }
};

// Adapted from https://github.com/Earthcomputer/aoc2023/blob/master/src/main.zig
const days = [_]Day{
    Day.create(@import("day1.zig")),
    Day.create(@import("day2.zig")),
    Day.create(@import("day3.zig")),
    Day.create(@import("day4.zig")),
    Day.create(@import("day5.zig")),
    Day.create(@import("day6.zig")),
    Day.create(@import("day7.zig")),
    Day.create(@import("day8.zig")),
    Day.create(@import("day9.zig")),
    Day.create(@import("day10.zig")),
    Day.create(@import("day11.zig")),
    Day.create(@import("day12.zig")),
};

fn callDay(daynum: u8, part: u8, file: *std.fs.File) !isize {
    if (0 == daynum or daynum > days.len) {
        return error.DayOutOfRange;
    }
    const day = days[daynum - 1];
    if (part == 1) {
        return try day.part1(file);
    } else if (part == 2) {
        return try day.part2(file);
    } else {
        return error.PartOutOfRange;
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
