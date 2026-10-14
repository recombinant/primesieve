//! @file   skipto_next_prime.c
//! @brief  Test primesieve.skipto() and primesieve.nextPrime().
//!
//! Copyright (C) 2026 Kim Walisch, <kim.walisch@gmail.com>
//!
//! This file is distributed under the BSD License. See the COPYING
//! file in the top level directory of kimwalisch/primesieve.
const std = @import("std");
const testing = std.testing;

test "skipto next prime" {
    const primesieve = @import("root.zig");

    const primes: []u64 = try primesieve.generatePrimes(u64, 0, 100_000);
    defer primesieve.free(primes);

    try testing.expectEqual(9_592, primes.len);

    var it: primesieve.Iterator = .init();
    defer it.deinit();

    const max_prime: u64 = primes[primes.len - 1];

    for (0..primes.len - 1) |i| {
        it.jumpTo(primes[i], max_prime);
        var prime = it.next().?;
        try testing.expectEqual(primes[i], prime);

        it.jumpTo(primes[i] + 1, max_prime);
        prime = it.next().?;
        try testing.expectEqual(primes[i + 1], prime);
    }

    it.jumpTo(0, max_prime);

    var sum: u64 = 0;

    // iterate over the primes below 10^9
    while (it.next()) |prime| {
        if (prime > 1_000_000_000)
            break;
        sum += prime;
    }
    try testing.expectEqual(sum, 24_739_512_092_254_535);

    it.jumpTo(max_prime / 2, max_prime);

    var prime = it.next().?;
    while (prime <= max_prime)
        prime = it.next().?;

    for (1..1000) |i| {
        prime = it.prev().?;
        try testing.expectEqual(primes[primes.len - i], prime);
    }

    it.jumpTo(18_446_744_073_709_551_556, 0);

    prime = it.next().?;
    try testing.expectEqual(18_446_744_073_709_551_557, prime);

    // // throws an uncaught runtime error in C++ code
    // // primesieve_iterator: cannot generate primes > 2^64
    //
    // // This test triggers a GCC bug if GCC version <= 12,
    // // hence we avoid running this test with GCC <= 12.
    // // See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=106627
    // for (0..100) |_| {
    //     prime = it.next() orelse unreachable;
    //     try testing.expectEqual(18_446_744_073_709_551_615, prime);
    // }

}
