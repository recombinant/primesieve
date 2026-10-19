//! @file   primesieve.h
//! @brief  primesieve C API. primesieve is a library for quickly
//!         generating prime numbers. If an error occurs, primesieve
//!         functions with a uint64_t return type return PRIMESIEVE_ERROR
//!         and the corresponding error message is printed to the
//!         standard error stream. libprimesieve also sets the C errno
//!         variable to EDOM if an error occurs.
//!
//! Copyright (C) 2026 Kim Walisch, <kim.walisch@gmail.com>
//!
//! This file is distributed under the BSD License.

const std = @import("std");
const primesieve = @import("libprimesieve");
// --------------------------------------------------------------
test "run all tests" {
    _ = @import("test_clear_primesieve_iterator2.zig");
    _ = @import("test_generate_n_primes2.zig");
    _ = @import("test_generate_primes2.zig");
    _ = @import("test_next_prime2.zig");
    _ = @import("test_prev_prime2.zig");
    _ = @import("test_jump_to_next_prime.zig");
    _ = @import("test_jump_to_prev_prime.zig");
}

// -------------------------------- include/primesieve/iterator.h
pub const Iterator = @import("iterator.zig").Iterator;

// ----------------------------------------- include/primesieve.h
/// primesieve functions return PRIMESIEVE_ERROR
/// (UINT64_MAX) if any error occurs.
pub const ERROR = std.math.maxInt(u64);

fn getPrimesieveType(comptime T: type) @TypeOf(primesieve.UINT64_PRIMES) {
    return comptime switch (T) {
        c_short => primesieve.SHORT_PRIMES,
        c_ushort => primesieve.USHORT_PRIMES,
        c_int => primesieve.INT_PRIMES,
        c_uint => primesieve.UINT_PRIMES,
        c_long => primesieve.LONG_PRIMES,
        c_ulong => primesieve.ULONG_PRIMES,
        c_longlong => primesieve.LONGLONG_PRIMES,
        c_ulonglong => primesieve.ULONGLONG_PRIMES,
        i16 => primesieve.INT16_PRIMES,
        u16 => primesieve.UINT16_PRIMES,
        i32 => primesieve.INT32_PRIMES,
        u32 => primesieve.UINT32_PRIMES,
        i64 => primesieve.INT64_PRIMES,
        u64 => primesieve.UINT64_PRIMES,
        else => @compileError("primesieve has not equivalent type for \"" ++ @typeName(T) ++ "\""),
    };
}

/// Get an array with the primes inside the
/// half-open interval [start, stop).
/// @param size  The size of the returned primes array.
/// @param type  The type of the primes to generate, e.g. INT_PRIMES.
///
/// In case an error occurs the error message is printed to the
/// standard error stream, the size is set to 0 and a NULL pointer
/// is returned. In order to distinguish an "error" from "no primes
/// found within [start, stop]" libprimesieve also sets the C errno
/// variable (from <errno.h>) to EDOM if any error occurs. By
/// checking errno after calling primesieve_generate_primes() users
/// can reliably detect errors.
///
/// void* primesieve_generate_primes(uint64_t start, uint64_t stop, size_t* size, int type);
///
/// Zig: Call primesieve.free() to free the allocated slice.
pub fn generatePrimes(comptime T: type, start: u64, stop: u64) ![]T {
    const primesieve_type = getPrimesieveType(T);
    var size: usize = 0;
    const generated: ?*anyopaque = primesieve.primesieve_generate_primes(start, stop, &size, primesieve_type);
    if (generated == null)
        return error.FailedGeneratePrimes;
    return @as([*]T, @ptrCast(@alignCast(generated)))[0..size];
}

/// Get an array with the first n primes >= start.
/// @param type  The type of the primes to generate, e.g. INT_PRIMES.
///
/// In case an error occurs the error message is printed to the
/// standard error stream and a NULL pointer is returned.
/// libprimesieve also sets the C errno variable (from <errno.h>)
/// to EDOM if any error occurs. The only advantage which checking
/// errno (after primesieve_generate_n_primes()) has over checking
/// if a NULL pointer has been returned, is that errno is not set
/// when calling primesieve_generate_n_primes(0, start, type) which
/// is valid (but useless) and which returns a NULL pointer.
///
/// void* primesieve_generate_n_primes(uint64_t n, uint64_t start, int type);
///
/// Zig: Call primesieve.free() to free the allocated slice.
pub fn generateNPrimes(comptime T: type, n: u64, start: u64) ![]T {
    const primesieve_type = getPrimesieveType(T);
    const generated: ?*anyopaque = primesieve.primesieve_generate_n_primes(n, start, primesieve_type);
    if (generated == null)
        return error.FailedGenerateNPrimes;
    return @as([*]T, @ptrCast(@alignCast(generated)))[0..n];
}

/// Deallocate a primes array created using the
/// primesieve_generate_primes() or primesieve_generate_n_primes()
/// functions.
///
/// void primesieve_free(void* primes);
///
/// Zig: Deallocates slice created using generatePrimes() or
///      generateNPrimes()
pub fn free(primes: anytype) void {
    switch (@typeInfo(@TypeOf(primes))) {
        .pointer => |p| {
            if (p.size == .slice) {
                primesieve.primesieve_free(primes.ptr);
                return;
            }
            unreachable;
        },
        else => unreachable,
    }
}

/// Find the nth prime.
/// By default all CPU cores are used, use
/// primesieve_set_num_threads(int threads) to change the
/// number of threads.
///
/// Note that each call to primesieve_nth_prime(n, start) incurs an
/// initialization overhead of O(sqrt(start)) even if n is tiny.
/// Hence it is not a good idea to use primesieve_nth_prime()
/// repeatedly in a loop to get the next (or previous) prime. For
/// this use case it is better to use a primesieve::iterator which
/// needs to be initialized only once.
///
/// @param n  if n = 0 finds the 1st prime >= start, <br/>
///           if n > 0 finds the nth prime > start, <br/>
///           if n < 0 finds the nth prime < start (backwards).
///
/// uint64_t primesieve_nth_prime(int64_t n, uint64_t start);
pub const nthPrime = primesieve.primesieve_nth_prime;

/// Count the primes within the interval [start, stop].
/// By default all CPU cores are used, use
/// primesieve_set_num_threads(int threads) to change the
/// number of threads.
///
/// Note that each call to primesieve_count_primes() incurs an
/// initialization overhead of O(sqrt(stop)) even if the interval
/// [start, stop] is tiny. Hence if you have written an algorithm
/// that makes many calls to primesieve_count_primes() it may be
/// preferable to use a primesieve::iterator which needs to be
/// initialized only once.
///
/// uint64_t primesieve_count_primes(uint64_t start, uint64_t stop);
pub const countPrimes = primesieve.primesieve_count_primes;

/// Count the twin primes within the interval [start, stop].
/// By default all CPU cores are used, use
/// primesieve_set_num_threads(int threads) to change the
/// number of threads.
///
/// uint64_t primesieve_count_twins(uint64_t start, uint64_t stop);
pub const countTwins = primesieve.primesieve_count_twins;

/// Count the prime triplets within the interval [start, stop].
/// By default all CPU cores are used, use
/// primesieve_set_num_threads(int threads) to change the
/// number of threads.
///
/// uint64_t primesieve_count_triplets(uint64_t start, uint64_t stop);
pub const countTriplets = primesieve.primesieve_count_triplets;

/// Count the prime quadruplets within the interval [start, stop].
/// By default all CPU cores are used, use
/// primesieve_set_num_threads(int threads) to change the
/// number of threads.
///
/// uint64_t primesieve_count_quadruplets(uint64_t start, uint64_t stop);
pub const countQuadruplets = primesieve.primesieve_count_quadruplets;

/// Count the prime quintuplets within the interval [start, stop].
/// By default all CPU cores are used, use
/// primesieve_set_num_threads(int threads) to change the
/// number of threads.
///
/// uint64_t primesieve_count_quintuplets(uint64_t start, uint64_t stop);
pub const countQuintuplets = primesieve.primesieve_count_quintuplets;

/// Count the prime sextuplets within the interval [start, stop].
/// By default all CPU cores are used, use
/// primesieve_set_num_threads(int threads) to change the
/// number of threads.
///
/// uint64_t primesieve_count_sextuplets(uint64_t start, uint64_t stop);
pub const countSextuplets = primesieve.primesieve_count_sextuplets;

/// Print the primes within the interval [start, stop]
/// to the standard output.
///
/// void primesieve_print_primes(uint64_t start, uint64_t stop);
pub const printPrimes = primesieve.primesieve_print_primes;

/// Print the twin primes within the interval [start, stop]
/// to the standard output.
///
/// void primesieve_print_twins(uint64_t start, uint64_t stop);
pub const printTwins = primesieve.primesieve_print_twins;

/// Print the prime triplets within the interval [start, stop]
/// to the standard output.
///
/// void primesieve_print_triplets(uint64_t start, uint64_t stop);
pub const printTriplets = primesieve.primesieve_print_triplets;

/// Print the prime quadruplets within the interval [start, stop]
/// to the standard output.
///
/// void primesieve_print_quadruplets(uint64_t start, uint64_t stop);
pub const printQuadruplets = primesieve.primesieve_print_quadruplets;

/// Print the prime quintuplets within the interval [start, stop]
/// to the standard output.
///
/// void primesieve_print_quintuplets(uint64_t start, uint64_t stop);
pub const printQuintuplets = primesieve.primesieve_print_quintuplets;

/// Print the prime sextuplets within the interval [start, stop]
/// to the standard output.
///
/// void primesieve_print_sextuplets(uint64_t start, uint64_t stop);
pub const printSextuplets = primesieve.primesieve_print_sextuplets;

/// Returns the largest valid stop number for primesieve.
/// @return 2^64-1 (UINT64_MAX).
///
/// uint64_t primesieve_get_max_stop(void);
pub const getMaxStop = primesieve.primesieve_get_max_stop;

/// Get the current set sieve size in KiB
///
/// int primesieve_get_sieve_size(void);
pub const getSieveSize = primesieve.primesieve_get_sieve_size;

/// Get the current set number of threads
///
/// int primesieve_get_num_threads(void);
pub const getNumThreads = primesieve.primesieve_get_num_threads;

/// Set the sieve size in KiB (kibibyte).
/// The best sieving performance is achieved with a sieve size
/// of your CPU's L1 or L2 cache size (per core).
/// @pre sieve_size >= 16 && <= 8192.
///
/// void primesieve_set_sieve_size(int sieve_size);
pub const setSieveSize = primesieve.primesieve_set_sieve_size;

/// Set the number of threads for use in
/// primesieve_count_*() and primesieve_nth_prime().
/// By default all CPU cores are used.
///
/// void primesieve_set_num_threads(int num_threads);
pub const setNumThreads = primesieve.primesieve_set_num_threads;

/// Get the primesieve version number, in the form “i.j”
///
/// const char* primesieve_version(void);
pub const version = primesieve.primesieve_version;
