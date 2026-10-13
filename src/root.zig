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
//!
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

// --------------------------------------------------------------
const std = @import("std");
const primesieve = @import("libprimesieve");

// --------------------------------------------------------------
// ----------------------------------------- include/primesieve.h

/// primesieve functions return PRIMESIEVE_ERROR
/// (UINT64_MAX) if any error occurs.
pub const ERROR = std.math.maxInt(u64);

/// Generate primes of short type
pub const SHORT_PRIMES = primesieve.SHORT_PRIMES;
/// Generate primes of unsigned short type
pub const USHORT_PRIMES = primesieve.USHORT_PRIMES;
/// Generate primes of int type
pub const INT_PRIMES = primesieve.INT_PRIMES;
/// Generate primes of unsigned int type
pub const UINT_PRIMES = primesieve.UINT_PRIMES;
/// Generate primes of long type
pub const LONG_PRIMES = primesieve.LONG_PRIMES;
/// Generate primes of unsigned long type
pub const ULONG_PRIMES = primesieve.ULONG_PRIMES;
/// Generate primes of long long type
pub const LONGLONG_PRIMES = primesieve.LONGLONG_PRIMES;
/// Generate primes of unsigned long long type
pub const ULONGLONG_PRIMES = primesieve.ULONGLONG_PRIMES;
/// Generate primes of int16_t type
pub const INT16_PRIMES = primesieve.INT16_PRIMES;
/// Generate primes of uint16_t type
pub const UINT16_PRIMES = primesieve.UINT16_PRIMES;
/// Generate primes of int32_t type
pub const INT32_PRIMES = primesieve.INT32_PRIMES;
/// Generate primes of uint32_t type
pub const UINT32_PRIMES = primesieve.UINT32_PRIMES;
/// Generate primes of int64_t type
pub const INT64_PRIMES = primesieve.INT64_PRIMES;
/// Generate primes of uint64_t type
pub const UINT64_PRIMES = primesieve.UINT64_PRIMES;

/// Get an array with the primes inside the interval [start, stop].
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
pub const generatePrimes = primesieve.primesieve_generate_primes;

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
pub const generateNPrimes = primesieve.primesieve_generate_n_primes;

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

/// Deallocate a primes array created using the
/// primesieve_generate_primes() or primesieve_generate_n_primes()
/// functions.
///
/// void primesieve_free(void* primes);
pub const free = primesieve.primesieve_free;

/// Get the primesieve version number, in the form “i.j”
///
/// const char* primesieve_version(void);
pub const version = primesieve.primesieve_version;

// --------------------------------------------------------------
// -------------------------------- include/primesieve/iterator.h

/// C prime iterator, please refer to @link iterator.h iterator.h
/// @endlink for more information.
///
pub const Iterator = primesieve.primesieve_iterator;

/// Initialize the primesieve iterator before first using it
///
/// void primesieve_init(primesieve_iterator* it);
pub const init = primesieve.primesieve_init;

/// Free all memory
///
/// void primesieve_free_iterator(primesieve_iterator* it);
pub const freeIterator = primesieve.primesieve_free_iterator;

/// Reset the start number to 0 and free most memory.
/// Keeps some smaller data structures in memory
/// (e.g. the IteratorData object) that are useful if the
/// primesieve_iterator is reused. The remaining memory
/// uses at most 2 kilobytes.
///
/// void primesieve_clear(primesieve_iterator* it);
pub const clear = primesieve.primesieve_clear;

/// Reset the primesieve iterator to start.
/// @param start      Generate primes >= start (or <= start).
/// @param stop_hint  Stop number optimization hint. E.g. if you want
///                   to generate the primes <= 1000 use
///                   stop_hint = 1000, if you don't know use
///                   UINT64_MAX.
///
/// void primesieve_jump_to(primesieve_iterator* it, uint64_t start, uint64_t stop_hint);
pub const jumpTo = primesieve.primesieve_jump_to;

/// Used internally by primesieve_next_prime().
/// primesieve_generate_next_primes() fills (overwrites) the primes
/// array with the next few primes (~ 2^10) that are larger than the
/// current largest prime in the primes array or with the
/// primes >= start if the primes array is empty.
/// Note that this function also updates the i & size member variables
/// of the primesieve_iterator struct. The size of the primes array
/// varies, but it is > 0 and usually close to 2^10.
/// If an error occurs primesieve_iterator.is_error is set to 1
/// and the primes array will contain PRIMESIEVE_ERROR.
///
/// void primesieve_generate_next_primes(primesieve_iterator*);
pub const generateNextPrimes = primesieve.primesieve_generate_next_primes;

/// Used internally by primesieve_prev_prime().
/// primesieve_generate_prev_primes() fills (overwrites) the primes
/// array with the next few primes ~ O(sqrt(n)) that are smaller than
/// the current smallest prime in the primes array or with the
/// primes <= start if the primes array is empty.
/// Note that this function also updates the i & size member variables
/// of the primesieve_iterator struct. The size of the primes array
/// varies, but it is > 0 and ~ O(sqrt(n)).
/// If an error occurs primesieve_iterator.is_error is set to 1
/// and the primes array will contain PRIMESIEVE_ERROR.
///
/// void primesieve_generate_prev_primes(primesieve_iterator*);
pub const generatePrevPrimes = primesieve.primesieve_generate_prev_primes;

/// Get the next prime.
/// Returns PRIMESIEVE_ERROR (UINT64_MAX) if any error occurs.
///
/// static inline uint64_t primesieve_next_prime(primesieve_iterator* it)
pub inline fn nextPrime(it: *Iterator) u64 {
    it.i += 1;
    if (it.i >= it.size) {
        @branchHint(.unlikely);
        generateNextPrimes(it);
    }
    return it.primes[it.i];
}

/// Get the previous prime.
/// primesieve_prev_prime(n) returns 0 for n <= 2.
/// Note that primesieve_next_prime() runs up to 2x faster than
/// primesieve_prev_prime(). Hence if the same algorithm can be written
/// using either primesieve_prev_prime() or primesieve_next_prime()
/// it is preferable to use primesieve_next_prime().
///
/// static inline uint64_t primesieve_prev_prime(primesieve_iterator* it)
pub inline fn prevPrime(it: *Iterator) u64 {
    if (it.i == 0) {
        @branchHint(.unlikely);
        generatePrevPrimes(it);
    }
    it.i -= 1;
    return it.primes[it.i];
}

test "run all tests" {
    _ = @import("test_clear_primesieve_iterator2.zig");
    _ = @import("test_generate_n_primes2.zig");
    _ = @import("test_generate_primes2.zig");
    _ = @import("test_next_prime2.zig");
    _ = @import("test_prev_prime2.zig");
    _ = @import("test_jump_to_next_prime.zig");
    _ = @import("test_jump_to_prev_prime.zig");
}
