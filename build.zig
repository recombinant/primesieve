const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("upstream", .{});

    const headers = b.addTranslateC(.{
        .root_source_file = upstream.path("include/primesieve.h"),
        .target = target,
        .optimize = optimize,
    });
    headers.addIncludePath(upstream.path("include"));
    _ = headers.addModule("headers");

    const mod = b.addModule("primesieve", .{
        .root_source_file = headers.getOutput(),
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });

    mod.addCSourceFiles(.{
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
    mod.addIncludePath(upstream.path("include"));

    const lib = b.addLibrary(.{
        .name = "primesieve",
        .root_module = mod,
        .linkage = .static,
    });

    lib.installHeader(upstream.path("include/primesieve.h"), "primesieve.h");
    lib.installHeader(upstream.path("include/primesieve/iterator.h"), "primesieve/iterator.h");
}
