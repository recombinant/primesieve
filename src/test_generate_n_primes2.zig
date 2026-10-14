//! Test n prime number generation.
//!
//! Copyright (C) 2026 Kim Walisch, <kim.walisch@gmail.com>
//!
//! This file is distributed under the BSD License. See the COPYING
//! file in the top level directory of kimwalisch/primesieve.
const std = @import("std");
const testing = std.testing;

test "generate n primes2" {
    const primesieve = @import("root.zig");

    var size: usize = 25;
    var primes: []u64 = try primesieve.generateNPrimes(u64, size, 0);
    defer primesieve.free(primes);

    try testing.expectEqual(size, primes.len);

    for (0..size) |i|
        try testing.expectEqual(small_primes[i], primes[i]);

    size = 20;
    primes = try primesieve.generateNPrimes(u64, size, 10_000_000_000_000_000);

    for (0..size) |i|
        try testing.expectEqual(large_primes[i], primes[i]);

    try testing.expectEqual(size, primes.len);

    // // 16 bit overflow at runtime
    // // throws an uncaught runtime error in C++ code
    // // store_n_primes(): uint16_t is too narrow for generating primes up to 146107
    // const primes16: [*c]u16 = @ptrCast(@alignCast(primesieve.generateNPrimes(100_000, (1 << 16) - 100, primesieve.UINT16_PRIMES)));
    // try testing.expectEqual(null, primes16);
}

// primes inside [0, 100]
const small_primes: [25]u64 =
    .{
        2,  3,  5,  7,  11,
        13, 17, 19, 23, 29,
        31, 37, 41, 43, 47,
        53, 59, 61, 67, 71,
        73, 79, 83, 89, 97,
    };

// primes inside [10^16, 10^16 + 1000]
const large_primes: [20]u64 =
    .{
        10_000_000_000_000_061,
        10_000_000_000_000_069,
        10_000_000_000_000_079,
        10_000_000_000_000_099,
        10_000_000_000_000_453,
        10_000_000_000_000_481,
        10_000_000_000_000_597,
        10_000_000_000_000_613,
        10_000_000_000_000_639,
        10_000_000_000_000_669,
        10_000_000_000_000_753,
        10_000_000_000_000_793,
        10_000_000_000_000_819,
        10_000_000_000_000_861,
        10_000_000_000_000_897,
        10_000_000_000_000_909,
        10_000_000_000_000_931,
        10_000_000_000_000_949,
        10_000_000_000_000_957,
        10_000_000_000_000_991,
    };
