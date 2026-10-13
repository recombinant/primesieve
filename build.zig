const std = @import("std");
const Build = std.Build;
const Translator = @import("translate_c").Translator;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    //-----------------------------------------------------------
    const upstream = b.dependency("upstream", .{});

    const libprimesieve_module: *Build.Module = b.addModule("libprimesieve", .{
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });

    libprimesieve_module.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = &.{
            "api.cpp",
            "api-c.cpp",
            "iterator.cpp",
            "iterator-c.cpp",
            "nthPrime.cpp",
            "popcount.cpp",
            "CountPrintPrimes.cpp",
            "CpuInfo.cpp",
            "Erat.cpp",
            "EratBig.cpp",
            "EratMedium.cpp",
            "EratSmall.cpp",
            "IteratorHelper.cpp",
            "LookupTables.cpp",
            "MemoryPool.cpp",
            "ParallelSieve.cpp",
            "PreSieve.cpp",
            "PrimeGenerator.cpp",
            "PrimeSieveClass.cpp",
            "RiemannR.cpp",
            "SievingPrimes.cpp",
        },
        .flags = &.{},
    });
    libprimesieve_module.addIncludePath(upstream.path("include"));

    const libprimesieve = b.addLibrary(.{
        .name = "libprimesieve",
        .root_module = libprimesieve_module,
        .linkage = .static,
    });
    libprimesieve.installHeader(upstream.path("include/primesieve.h"), "primesieve.h");
    libprimesieve.installHeader(upstream.path("include/primesieve/iterator.h"), "primesieve/iterator.h");
    b.installArtifact(libprimesieve);

    //-----------------------------------------------------------
    const translate_c = b.dependency("translate_c", .{});

    const trans_libprimesieve: Translator = .init(translate_c, .{
        .c_source_file = upstream.path("include/primesieve.h"),
        .target = target,
        .optimize = optimize,
        .default_init = false,
    });
    trans_libprimesieve.linkLibrary(libprimesieve);

    const primesieve_module: *Build.Module = b.addModule("primesieve", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,

        .imports = &.{
            .{ .name = "libprimesieve", .module = trans_libprimesieve.mod },
        },
    });

    // ----------------------------------------------------------
    const test_step = b.step("test", "Run all tests");

    const module_tests = b.addTest(.{
        .root_module = primesieve_module,
    });
    const run_module_tests = b.addRunArtifact(module_tests);
    test_step.dependOn(&run_module_tests.step);
}
