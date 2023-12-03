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

        pub fn clear(self: *Self) void {
            self.len = 0;
        }
    };
}
