const std = @import("std");
const primesieve = @import("primesieve");

pub fn main() !void {
    var it: primesieve.primesieve_iterator = undefined;
    primesieve.primesieve_init(&it);
    var prime: u64 = undefined;

    while (true) {
        prime = primesieve.primesieve_next_prime(&it);
        if (prime >= 1000)
            break;
        std.debug.print("{} ", .{prime});
    }
    primesieve.primesieve_free_iterator(&it);
}
