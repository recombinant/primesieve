// Build a Zig program that finds the nth prime.
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const primesieve_dependency = b.dependency("primesieve", .{});
    const primesieve_module = primesieve_dependency.module("primesieve");

    const exe = b.addExecutable(.{
        .name = "nth_prime",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),

            .target = target,
            .optimize = optimize,

            .imports = &.{
                .{ .name = "primesieve", .module = primesieve_module },
            },
        }),
    });

    b.installArtifact(exe);

    const run_command = b.addRunArtifact(exe);
    run_command.step.dependOn(b.getInstallStep());
    run_command.addPassthruArgs();

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_command.step);
}
