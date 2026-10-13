//! @file   next_prime2.c
//! @brief  Test primesieve.nextPrime().
//!
//! Copyright (C) 2026 Kim Walisch, <kim.walisch@gmail.com>
//!
//! This file is distributed under the BSD License. See the COPYING
//! file in the top level directory of kimwalisch/primesieve.
const std = @import("std");
const testing = std.testing;

test "next prime2" {
    const primesieve = @import("root.zig");

    var size: usize = 0;
    const generated: ?*anyopaque = primesieve.generatePrimes(0, 100_000, &size, primesieve.UINT64_PRIMES);
    try testing.expect(generated != null);
    try testing.expectEqual(9_592, size);
    const primes = @as([*]u64, @ptrCast(@alignCast(generated)))[0..size];

    var it: primesieve.Iterator = undefined;
    primesieve.init(&it);

    const max_prime: u64 = primes[size - 1];

    for (0..size - 1) |i| {
        primesieve.jumpTo(&it, primes[i], max_prime);
        var prime: u64 = primesieve.nextPrime(&it);
        try testing.expectEqual(primes[i], prime);

        primesieve.jumpTo(&it, primes[i] + 1, max_prime);
        prime = primesieve.nextPrime(&it);
        try testing.expectEqual(primes[i + 1], prime);
    }

    primesieve.jumpTo(&it, 0, max_prime);

    var sum: u64 = 0;

    // Iterate over the primes <= 10^9
    while (true) {
        const prime = primesieve.nextPrime(&it);
        if (prime > 1_000_000_000)
            break;
        sum += prime;
    }

    try testing.expectEqual(24_739_512_092_254_535, sum);

    primesieve.jumpTo(&it, max_prime / 2, max_prime);

    var prime = primesieve.nextPrime(&it);
    while (prime <= max_prime)
        prime = primesieve.nextPrime(&it);

    for (1..1_000) |i| {
        prime = primesieve.prevPrime(&it);
        try testing.expectEqual(primes[size - i], prime);
    }

    primesieve.jumpTo(&it, 18_446_744_073_709_551_556, 0);

    prime = primesieve.nextPrime(&it);
    try testing.expectEqual(18_446_744_073_709_551_557, prime);

    // // throws an uncaught runtime error in C++ code
    // // primesieve_iterator: cannot generate primes > 2^64
    //
    // // This test triggers a GCC bug if GCC version <= 12,
    // // hence we avoid running this test with GCC <= 12.
    // // See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=106627
    //
    // // Make sure that primesieve.nextPrime() returns
    // // PRIMESIEVE.ERROR indefinitely when trying to
    // // generate primes > 2^64.
    // for (0..1_000) |_| {
    //     prime = primesieve.nextPrime(&it);
    //     try testing.expectEqual(primesieve.ERROR, prime);
    // }

    primesieve.free(primes.ptr);
    primesieve.freeIterator(&it);
}
