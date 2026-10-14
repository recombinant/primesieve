//! @file   generate_primes2.c
//! @brief  Test prime number generation.
//!
//! Copyright (C) 2022 Kim Walisch, <kim.walisch@gmail.com>
//!
//! This file is distributed under the BSD License. See the COPYING
//! file in the top level directory of kimwalisch/primesieve.
const std = @import("std");
const testing = std.testing;

test "generate primes2" {
    const primesieve = @import("root.zig");

    var primes: []u64 = try primesieve.generatePrimes(u64, 0, 100);
    try testing.expectEqual(25, primes.len);

    for (primes, 0..) |prime, i|
        try testing.expectEqual(small_primes[i], prime);

    primesieve.free(primes);

    primes = try primesieve.generatePrimes(u64, 0, 1_000);
    try testing.expectEqual(168, primes.len);
    primesieve.free(primes);

    primes = try primesieve.generatePrimes(u64, 0, 1_000_000);
    try testing.expectEqual(78_498, primes.len);
    primesieve.free(primes);

    primes = try primesieve.generatePrimes(u64, 1_000_003, 9_999_991);
    try testing.expectEqual(664_579 - 78_498, primes.len);
    primesieve.free(primes);

    primes = try primesieve.generatePrimes(u64, 1_000_000, 1_000_000);
    try testing.expectEqual(0, primes.len);
    primesieve.free(primes);

    primes = try primesieve.generatePrimes(u64, 18_446_744_073_709_550_672, 18_446_744_073_709_551_615);
    try testing.expectEqual(20, primes.len);

    for (primes, 0..) |prime, i|
        try testing.expectEqual(large_primes[i], prime);

    primesieve.free(primes);

    // // 32 bit overflow at runtime
    // // throws an uncaught runtime error in C++ code
    // // store_primes(): int32_t is too narrow for generating primes up to 2147484648
    // const primes32: [*c]u32 = @ptrCast(@alignCast(primesieve.generatePrimes((1 << 31) - 1_000, (1 << 31) + 1_000, &size, primesieve.INT32_PRIMES)));
    // try testing.expectEqual(null, primes32);
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

// primes inside [18446744073709550681, 18446744073709551533]
const large_primes: [20]u64 =
    .{
        18_446_744_073_709_550_681,
        18_446_744_073_709_550_717,
        18_446_744_073_709_550_719,
        18_446_744_073_709_550_771,
        18_446_744_073_709_550_773,
        18_446_744_073_709_550_791,
        18_446_744_073_709_550_873,
        18_446_744_073_709_551_113,
        18_446_744_073_709_551_163,
        18_446_744_073_709_551_191,
        18_446_744_073_709_551_253,
        18_446_744_073_709_551_263,
        18_446_744_073_709_551_293,
        18_446_744_073_709_551_337,
        18_446_744_073_709_551_359,
        18_446_744_073_709_551_427,
        18_446_744_073_709_551_437,
        18_446_744_073_709_551_521,
        18_446_744_073_709_551_533,
        18_446_744_073_709_551_557,
    };
