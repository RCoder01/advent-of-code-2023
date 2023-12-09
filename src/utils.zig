const std = @import("std");

pub fn find(buf: []u8, delim: u8) ?usize {
    var i: usize = 0;
    while (i < buf.len) : (i += 1) {
        if (buf[i] == delim) {
            return i;
        }
    }
    return null;
}

pub fn BufferList(comptime N: comptime_int, comptime T: type) type {
    return struct {
        buf: [N]T = undefined,
        len: usize = 0,
        const Self = @This();

        pub fn append(self: *Self, e: T) !void {
            if (self.len == N) {
                return error.capacityReached;
            }
            self.buf[self.len] = e;
            self.len += 1;
        }

        pub fn data(self: *Self) []T {
            return self.buf[0..self.len];
        }

        pub fn const_data(self: *const Self) []const T {
            return self.buf[0..self.len];
        }

        pub fn clear(self: *Self) void {
            self.len = 0;
        }

        pub fn pop(self: *Self) ?T {
            if (self.len == 0) {
                return null;
            }
            self.len -= 1;
            return self.buf[self.len];
        }
    };
}

const Split = struct {
    line: []u8,
    delim: u8,
    const Self = @This();

    pub fn next(self: *Self) ?[]u8 {
        const first = find(self.line, self.delim) orelse return null;
        const ret = self.line[0..first];
        self.line = self.line[first..];
        return ret;
    }
};

pub fn SplitNums(comptime T: type) type {
    return struct {
        line: []u8,
        const Self = @This();

        pub fn next(self: *Self) !?T {
            var i: usize = 0;
            var num_start: ?usize = null;
            while (i < self.line.len) : (i += 1) {
                if (std.ascii.isDigit(self.line[i]) or self.line[i] == '-') {
                    num_start = i;
                    break;
                }
            }
            var num_end = (num_start orelse return null) + 1;
            i += 1;
            while (i < self.line.len and std.ascii.isDigit(self.line[i])) : (i += 1) {
                num_end += 1;
            }
            const num = try std.fmt.parseInt(T, self.line[num_start.?..num_end], 10);
            self.line = self.line[num_end..];
            return num;
        }
    };
}

// pub fn StackMap(comptime N: comptime_int, comptime K: type, comptime V: type) type {
//     return struct {
//         kbuf: [N]K = undefined,
//         vbuf: [N]V = undefined,
//         len: usize = 0,
//         const Self = @This();

//         pub fn
//     }
// }
