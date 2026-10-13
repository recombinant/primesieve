//! Test primesieve.clear() of primesieve.Iterator.
//!
//! Copyright (C) 2026 Kim Walisch, <kim.walisch@gmail.com>
//!
//! This file is distributed under the BSD License. See the COPYING
//! file in the top level directory of kimwalisch/primesieve.
const std = @import("std");
const testing = std.testing;

test "clear primesieve iterator" {
    const primesieve = @import("root.zig");

    var it: primesieve.Iterator = undefined;
    primesieve.init(&it);

    var primes: u64 = 0;

    for (0..10) |_| {
        primesieve.clear(&it);
        var prime: u64 = primesieve.nextPrime(&it);
        while (prime < 100_000) {
            primes += 1;
            prime = primesieve.nextPrime(&it);
        }
    }

    try testing.expectEqual(9592 * 10, primes);

    primesieve.freeIterator(&it);
    const prime: u64 = primesieve.nextPrime(&it);

    try testing.expectEqual(2, prime);

    primesieve.freeIterator(&it);
}
