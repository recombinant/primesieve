//! @file   skipto_prev_prime.c
//! @brief  Test primesieve.jumpTo() and primesieve.prevPrime().
//!
//! Copyright (C) 2026 Kim Walisch, <kim.walisch@gmail.com>
//!
//! This file is distributed under the BSD License. See the COPYING
//! file in the top level directory of kimwalisch/primesieve.
const std = @import("std");
const testing = std.testing;

test "jump to prev prime" {
    const primesieve = @import("root.zig");

    const primes: []u64 = try primesieve.generatePrimes(u64, 0, 100_000);
    defer primesieve.free(primes);

    try testing.expectEqual(9_592, primes.len);

    var it: primesieve.Iterator = .init();
    defer it.deinit();

    {
        var i: usize = primes.len;
        while (i > 1) {
            i -= 1;

            it.jumpTo(primes[i], 0);
            var prime = it.prev() orelse unreachable;
            try testing.expectEqual(primes[i], prime);

            it.jumpTo(primes[i] - 1, 0);
            prime = it.prev() orelse unreachable;
            try testing.expectEqual(primes[i - 1], prime);
        }
    }
    it.jumpTo(100_000_000, 0);

    var sum: u64 = 0;

    // iterate over the primes below 10^8
    while (it.prev()) |prime| {
        if (prime == 0)
            break;
        sum += prime;
    }
    try testing.expectEqual(279_209_790_387_276, sum);

    for (0..1_000) |_| {
        const prime = it.prev() orelse unreachable;
        try testing.expectEqual(0, prime);
    }

    for (0..1_000) |i| {
        const prime = it.next() orelse unreachable;
        try testing.expectEqual(primes[i], prime);
    }

    it.jumpTo(primes[primes.len - 2], 0);

    for (0..1_000) |i| {
        const p2 = primes[primes.len - (i + 2)];
        const prime = it.prev() orelse unreachable;
        try testing.expectEqual(p2, prime);
    }

    for (0..1_000) |i| {
        const p1 = primes.len - 1_000 + i;
        const prime = it.next() orelse unreachable;
        try testing.expectEqual(primes[p1], prime);
    }
}
