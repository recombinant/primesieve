// Zig program that finds the nth prime.
const std = @import("std");
const Io = std.Io;
const primesieve = @import("primesieve");

pub fn main(init: std.process.Init) !void {
    const io: Io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    const args = try init.minimal.args.toSlice(init.arena.allocator());

    var n: i64 = 1000;
    if (args.len > 1)
        n = try std.fmt.parseInt(i64, args[1], 10);

    const prime: u64 = primesieve.nthPrime(n, 0);
    try stdout_writer.print("{}th prime = {}\n", .{ n, prime });

    try stdout_writer.flush();
}
