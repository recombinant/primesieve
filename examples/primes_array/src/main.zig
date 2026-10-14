// Zig program to generate an array of primes.
const std = @import("std");
const Io = std.Io;
const primesieve = @import("primesieve");

pub fn main(init: std.process.Init) !void {
    const io: Io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    const start: u64 = 0;
    const stop: u64 = 1000;

    var primes: []c_int = undefined;

    // Get an array with the primes <= 1000
    primes = try primesieve.generatePrimes(c_int, start, stop);

    for (primes) |prime|
        try stdout_writer.print("{} ", .{prime});
    try stdout_writer.writeByte('\n');

    primesieve.free(primes);

    const n: u64 = 1_000;

    // Get an array with the first 1000 primes
    primes = try primesieve.generateNPrimes(c_int, n, start);

    for (primes) |prime|
        try stdout_writer.print("{} ", .{prime});
    try stdout_writer.writeByte('\n');

    primesieve.free(primes);

    try stdout_writer.flush();
}
