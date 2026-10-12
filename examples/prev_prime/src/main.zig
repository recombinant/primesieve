/// Iterate backwards over primes using primesieve.Iterator.
///
/// Note that primesieve.nextPrime() runs up to 2x faster and uses
/// only half as much memory as primesieve.prevPrime(). Hence if
/// it is possible to write the same algorithm using either
/// primesieve.prevPrime() or primesieve.nextPrime() then it is
/// preferable to use primesieve.nextPrime().
const std = @import("std");
const Io = std.Io;
const primesieve = @import("primesieve");

pub fn main(init: std.process.Init) !void {
    const io: Io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    const args = try init.minimal.args.toSlice(init.arena.allocator());

    var limit: u64 = 10_000_000_000;

    if (args.len > 1)
        limit = try std.fmt.parseInt(u64, args[1], 10);

    var it: primesieve.Iterator = undefined;
    primesieve.init(&it);

    // primesieve.jumpTo(&it, start_number, stop_hint)
    primesieve.jumpTo(&it, limit, 0);
    var sum: u64 = 0;

    // Backwards iterate over the primes <= limit
    while (true) {
        const prime = primesieve.prevPrime(&it);
        if (prime == 0)
            break;
        sum += prime;
    }
    primesieve.freeIterator(&it);
    try stdout_writer.print("Sum of the primes: {}\n", .{sum});

    // Note that since sum is a 64-bit variable the result
    // will be incorrect (due to integer overflow) if
    // limit > 10^10. However we do allow limits > 10^10
    // since this is useful for benchmarking.
    if (limit > 10_000_000_000)
        try stdout_writer.writeAll("Warning: sum is likely incorrect due to 64-bit integer overflow!");

    try stdout_writer.flush();
}
