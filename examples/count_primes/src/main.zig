// Zig program that shows how to count primes.
const std = @import("std");
const Io = std.Io;
const primesieve = @import("primesieve");

pub fn main(init: std.process.Init) !void {
    const io: Io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    const count = primesieve.countPrimes(0, 1_000);
    try stdout_writer.print("Primes <= 1000: {} \n", .{count});

    try stdout_writer.flush();
}
