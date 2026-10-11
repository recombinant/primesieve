const std = @import("std");
const primesieve = @import("primesieve");

pub fn main() !void {
    var it: primesieve.Iterator = undefined;
    primesieve.init(&it);
    var prime: u64 = undefined;

    while (true) {
        prime = primesieve.nextPrime(&it);
        if (prime >= 1000)
            break;
        std.debug.print("{} ", .{prime});
    }
    primesieve.freeIterator(&it);
}
