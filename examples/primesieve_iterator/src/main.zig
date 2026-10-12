// Zig program to iterate over primes using C primesieve.iterator.
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

    // Indicate exact bounds to improve performance
    primesieve.jumpTo(&it, 0, limit);

    var sum: u64 = 0;

    // Iterate over the primes <= 10^9
    while (true) {
        const prime = primesieve.nextPrime(&it);
        if (prime > limit)
            break;
        sum += prime;
    }

    primesieve.freeIterator(&it);
    try stdout_writer.print("Sum of the primes <= {}: {}\n", .{ limit, sum });

    try stdout_writer.flush();
}
