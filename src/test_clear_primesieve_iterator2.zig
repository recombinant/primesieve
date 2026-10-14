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

    var it: primesieve.Iterator = .init();
    defer it.deinit();

    var prime_count: u64 = 0;

    for (0..10) |_| {
        it.clear();

        while (it.next()) |prime| {
            if (prime >= 100_000)
                break;
            prime_count += 1;
        }
    }

    try testing.expectEqual(9592 * 10, prime_count);

    it.clear();

    const optional_prime: ?u64 = it.next();

    try testing.expect(optional_prime != null);
    try testing.expectEqual(2, optional_prime.?);
}
