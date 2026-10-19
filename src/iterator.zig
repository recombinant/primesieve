//! @file   iterator.h
//! @brief  primesieve_iterator allows to easily iterate over primes
//!         both forwards and backwards. Generating the first prime
//!         has a complexity of O(r log log r) operations with
//!         r = n^0.5, after that any additional prime is generated in
//!         amortized O(log n log log n) operations. The memory usage
//!         is about PrimePi(n^0.5) * 8 bytes.
//!
//!         The @link primesieve_iterator.c primesieve_iterator.c
//!         @endlink example shows how to use primesieve_iterator.
//!         If any error occurs primesieve_next_prime() and
//!         primesieve_prev_prime() return PRIMESIEVE_ERROR.
//!         Furthermore primesieve_iterator.is_error is initialized
//!         to 0 and set to 1 if any error occurs.
//!
//! Copyright (C) 2026 Kim Walisch, <kim.walisch@gmail.com>
//!
//! This file is distributed under the BSD License. See the COPYING
//! file in the top level directory.
const std = @import("std");
const primesieve = @import("libprimesieve");

// --------------------------------------------------------------
// ------ wrapper around https://github.com/kimwalisch/primesieve
// -------------------------------- include/primesieve/iterator.h

// C prime iterator, please refer to @link iterator.h iterator.h
// @endlink for more information.
pub const Iterator = extern struct {
    // Current index of the primes array
    i: usize = 0,
    // Current number of primes in the primes array
    size: usize = 0,
    // Generate primes >= start
    start: u64 = 0,
    // Generate primes <= stop_hint
    stop_hint: u64 = 0,
    // The primes array.
    // The current smallest prime can be accessed using primes[0].
    // The current largest prime can be accessed using primes[size-1].
    primes: [*c]u64,
    // Pointer to internal IteratorData data structure
    memory: ?*anyopaque,
    // Initialized to 0, set to 1 if any error occurs
    is_error: c_int,

    /// Initialize the primesieve iterator before first using it
    ///
    /// void primesieve_init(primesieve_iterator* it);
    pub fn init() Iterator {
        return .{
            .i = 0,
            .size = 0,
            .start = 0,
            .stop_hint = std.math.maxInt(u64),
            .primes = null,
            .memory = null,
            .is_error = @intFromBool(false),
        };
    }

    /// Free all memory
    ///
    /// void primesieve_free_iterator(primesieve_iterator* it);
    pub fn deinit(self: *Iterator) void {
        primesieve.primesieve_free_iterator(@ptrCast(@alignCast(self)));
    }
    /// Reset the start number to 0 and free most memory.
    /// Keeps some smaller data structures in memory
    /// (e.g. the IteratorData object) that are useful if the
    /// primesieve_iterator is reused. The remaining memory
    /// uses at most 2 kilobytes.
    ///
    /// void primesieve_clear(primesieve_iterator* it);
    pub fn clear(self: *Iterator) void {
        primesieve.primesieve_clear(@ptrCast(@alignCast(self)));
    }

    /// Reset the primesieve iterator to start.
    /// @param start      Generate primes >= start (or <= start).
    /// @param stop_hint  Stop number optimization hint. E.g. if you want
    ///                   to generate the primes <= 1000 use
    ///                   stop_hint = 1000, if you don't know use
    ///                   UINT64_MAX.
    ///
    /// void primesieve_jump_to(primesieve_iterator* it, uint64_t start, uint64_t stop_hint);
    pub fn jumpTo(self: *Iterator, start: u64, stop_hint: u64) void {
        primesieve.primesieve_jump_to(@ptrCast(@alignCast(self)), start, stop_hint);
    }

    // Used internally by primesieve_next_prime().
    // primesieve_generate_next_primes() fills (overwrites) the primes
    // array with the next few primes (~ 2^10) that are larger than the
    // current largest prime in the primes array or with the
    // primes >= start if the primes array is empty.
    // Note that this function also updates the i & size member variables
    // of the primesieve_iterator struct. The size of the primes array
    // varies, but it is > 0 and usually close to 2^10.
    // If an error occurs primesieve_iterator.is_error is set to 1
    // and the primes array will contain PRIMESIEVE_ERROR.
    //
    // void primesieve_generate_next_primes(primesieve_iterator*);

    // Used internally by primesieve_prev_prime().
    // primesieve_generate_prev_primes() fills (overwrites) the primes
    // array with the next few primes ~ O(sqrt(n)) that are smaller than
    // the current smallest prime in the primes array or with the
    // primes <= start if the primes array is empty.
    // Note that this function also updates the i & size member variables
    // of the primesieve_iterator struct. The size of the primes array
    // varies, but it is > 0 and ~ O(sqrt(n)).
    // If an error occurs primesieve_iterator.is_error is set to 1
    // and the primes array will contain PRIMESIEVE_ERROR.
    //
    // void primesieve_generate_prev_primes(primesieve_iterator*);

    /// Get the next prime.
    /// Returns PRIMESIEVE_ERROR (UINT64_MAX) if any error occurs.
    ///
    /// static inline uint64_t primesieve_next_prime(primesieve_iterator* it)
    pub inline fn next(self: *Iterator) ?u64 {
        self.i += 1;
        if (self.i >= self.size) {
            @branchHint(.unlikely);
            primesieve.primesieve_generate_next_primes(@ptrCast(@alignCast(self)));

            if (self.is_error != 0) {
                @branchHint(.unlikely);
                return null;
            }
        }
        return self.primes[self.i];
    }

    /// Get the previous prime.
    /// primesieve_prev_prime(n) returns 0 for n <= 2.
    /// Note that primesieve_next_prime() runs up to 2x faster than
    /// primesieve_prev_prime(). Hence if the same algorithm can be written
    /// using either primesieve_prev_prime() or primesieve_next_prime()
    /// it is preferable to use primesieve_next_prime().
    ///
    /// static inline uint64_t primesieve_prev_prime(primesieve_iterator* it)
    pub inline fn prev(self: *Iterator) ?u64 {
        if (self.i == 0) {
            @branchHint(.unlikely);
            primesieve.primesieve_generate_prev_primes(@ptrCast(@alignCast(self)));

            if (self.is_error != 0) {
                @branchHint(.unlikely);
                return null;
            }
        }
        self.i -= 1;
        return self.primes[self.i];
    }
};
