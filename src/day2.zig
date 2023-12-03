const std = @import("std");
const utils = @import("utils.zig");

pub fn part1(file: *std.fs.File) !i32 {
    var buf: [200]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    var game_num: i32 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        game_num += 1;
        const first = utils.find(line, ':') orelse return error.MissingCharacter;
        var games = line[first + 2 ..];
        if (games[games.len - 1] == '\n') {
            games = games[0 .. games.len - 1];
        }
        var red: i32 = 0;
        var green: i32 = 0;
        var blue: i32 = 0;
        var plausible = true;
        while (games.len > 0) {
            const end = utils.find(games, ';') orelse games.len - 1;
            const num = utils.find(games, ' ') orelse return error.MissingCharacter;
            var color = utils.find(games, ',') orelse games.len - 1;
            if (end < color) {
                color = end;
            }
            const value = std.fmt.parseInt(i32, games[0..num], 10) catch return error.InvalidNumber;
            const color_str = games[num + 1 .. color];
            if (std.mem.eql(u8, color_str, "red")) {
                red += value;
            } else if (std.mem.eql(u8, color_str, "green")) {
                green += value;
            } else if (std.mem.eql(u8, color_str, "blue")) {
                blue += value;
            } else {
                return error.InvalidColor;
            }
            if (color + 2 < games.len) {
                games = games[color + 2 ..];
            } else {
                games = &[0]u8{};
            }
            if (end == color) {
                if (!(red <= 12 and green <= 13 and blue <= 14)) {
                    plausible = false;
                }
                red = 0;
                green = 0;
                blue = 0;
            }
        }
        if (plausible) {
            // std.debug.print("{d}\n", .{game_num});
            sum += game_num;
        }
    }
    return sum;
}

pub fn part2(file: *std.fs.File) !i32 {
    var buf: [200]u8 = undefined;
    const reader = file.reader();
    var sum: i32 = 0;
    var game_num: i32 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        game_num += 1;
        const first = utils.find(line, ':') orelse return error.MissingCharacter;
        var games = line[first + 2 ..];
        if (games[games.len - 1] == '\n') {
            games = games[0 .. games.len - 1];
        }
        var red: i32 = 0;
        var green: i32 = 0;
        var blue: i32 = 0;
        var min_red: i32 = 0;
        var min_green: i32 = 0;
        var min_blue: i32 = 0;
        while (games.len > 0) {
            const end = utils.find(games, ';') orelse games.len - 1;
            const num = utils.find(games, ' ') orelse return error.MissingCharacter;
            var color = utils.find(games, ',') orelse games.len - 1;
            if (end < color) {
                color = end;
            }
            const value = std.fmt.parseInt(i32, games[0..num], 10) catch return error.InvalidNumber;
            const color_str = games[num + 1 .. color];
            if (std.mem.eql(u8, color_str, "red")) {
                red += value;
            } else if (std.mem.eql(u8, color_str, "green")) {
                green += value;
            } else if (std.mem.eql(u8, color_str, "blue")) {
                blue += value;
            } else {
                return error.InvalidColor;
            }
            if (color + 2 < games.len) {
                games = games[color + 2 ..];
            } else {
                games = &[0]u8{};
            }
            if (end == color) {
                // std.debug.print("{d} {d} {d}\n", .{ red, green, blue });
                if (min_red < red) {
                    min_red = red;
                }
                red = 0;
                if (min_green < green) {
                    min_green = green;
                }
                green = 0;
                if (min_blue < blue) {
                    min_blue = blue;
                }
                blue = 0;
            }
        }
        sum += min_red * min_green * min_blue;
    }
    return sum;
}
