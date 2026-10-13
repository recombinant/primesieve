//! @file   prev_prime2.c
//! @brief  Test primesieve.prevPrime().
//!
//! Copyright (C) 2026 Kim Walisch, <kim.walisch@gmail.com>
//!
//! This file is distributed under the BSD License. See the COPYING
//! file in the top level directory of kimwalisch/primesieve.
const std = @import("std");
const testing = std.testing;

test "clear primesieve iterator" {
    const primesieve = @import("root.zig");

    var size: usize = 0;
    const generated: ?*anyopaque = primesieve.generatePrimes(0, 100_000, &size, primesieve.UINT64_PRIMES);
    try testing.expect(generated != null);
    try testing.expectEqual(9_592, size);
    const primes = @as([*]u64, @ptrCast(@alignCast(generated)))[0..size];

    var it: primesieve.Iterator = undefined;
    primesieve.init(&it);

    {
        var i: usize = size;
        while (i > 1) {
            i -= 1;
            primesieve.jumpTo(&it, primes[i], 0);
            var prime = primesieve.prevPrime(&it);
            try testing.expectEqual(primes[i], prime);

            primesieve.jumpTo(&it, primes[i] - 1, 0);
            prime = primesieve.prevPrime(&it);
            try testing.expectEqual(primes[i - 1], prime);
        }
    }

    primesieve.jumpTo(&it, 100_000_000, 0);

    var sum: u64 = 0;

    // iterate over the primes <= 10^8
    while (true) {
        const prime = primesieve.prevPrime(&it);
        if (prime == 0)
            break;
        sum += prime;
    }
    try testing.expectEqual(279_209_790_387_276, sum);

    // Test iterating past the stop_hint
    primesieve.jumpTo(&it, 100_000_000, 5_000_000);
    sum = 0;

    // iterate over the primes <= 10^8
    while (true) {
        const prime = primesieve.prevPrime(&it);
        if (prime == 0)
            break;
        sum += prime;
    }
    try testing.expectEqual(279_209_790_387_276, sum);

    for (0..1_000) |_| {
        const prime = primesieve.prevPrime(&it);
        try testing.expectEqual(0, prime);
    }

    for (0..1_000) |i| {
        const prime = primesieve.nextPrime(&it);
        try testing.expectEqual(primes[i], prime);
    }

    primesieve.jumpTo(&it, primes[size - 1] - 1, 0);

    for (0..1_000) |i| {
        const p2 = primes[size - (i + 2)];
        const prime = primesieve.prevPrime(&it);
        try testing.expectEqual(p2, prime);
    }

    for (0..1_000) |i| {
        const p1 = size - 1_000 + i;
        const prime = primesieve.nextPrime(&it);
        try testing.expectEqual(primes[p1], prime);
    }

    primesieve.free(primes.ptr);
    primesieve.freeIterator(&it);
}
