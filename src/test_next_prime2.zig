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

    const primes: []u64 = try primesieve.generatePrimes(u64, 0, 100_000);
    defer primesieve.free(primes);

    try testing.expectEqual(9_592, primes.len);

    var it: primesieve.Iterator = .init();
    defer it.deinit();

    const max_prime: u64 = primes[primes.len - 1];

    for (0..primes.len - 2) |i| {
        it.jumpTo(primes[i], max_prime);
        var prime: u64 = it.next() orelse unreachable;
        try testing.expectEqual(primes[i], prime);

        it.jumpTo(primes[i] + 1, max_prime);
        prime = it.next() orelse unreachable;
        try testing.expectEqual(primes[i + 1], prime);
    }

    it.jumpTo(0, max_prime);

    var sum: u64 = 0;

    // Iterate over the primes <= 10^9
    while (it.next()) |prime| {
        if (prime > 1_000_000_000)
            break;
        sum += prime;
    }
    try testing.expectEqual(24_739_512_092_254_535, sum);

    it.jumpTo(max_prime / 2, max_prime);

    while (it.next()) |prime|
        if (prime > max_prime)
            break;

    var i: usize = 1;
    while (it.prev()) |prime| : (i += 1) {
        if (i >= 1000)
            break;
        try testing.expectEqual(primes[primes.len - i], prime);
    }

    it.jumpTo(18_446_744_073_709_551_556, 0);

    const prime = it.next() orelse unreachable;
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
    //     prime = it.next() orelse unreachable;
    //     try testing.expectEqual(primesieve.ERROR, prime);
    // }

}
