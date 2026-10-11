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

    //-----------------------------------------------------------
    const translate_c = b.dependency("translate_c", .{});

    const trans_libprimesieve: Translator = .init(translate_c, .{
        .c_source_file = upstream.path("include/primesieve.h"),
        .target = target,
        .optimize = optimize,
    });
    trans_libprimesieve.linkLibrary(libprimesieve);

    const primesieve_module: *Build.Module = b.addModule("primesieve", .{
        .target = target,
        .optimize = optimize,

        .imports = &.{
            .{ .name = "libprimesieve", .module = trans_libprimesieve.mod },
        },
    });
    _ = primesieve_module;

    // ----------------------------------------------------------
    const main_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    main_mod.addImport("primesieve", trans_libprimesieve.mod);
    const main_exe = b.addExecutable(.{
        .name = "main",
        .root_module = main_mod,
    });
    // b.installArtifact(main_exe);

    const run_step = b.step("run", "Build and run the executable");
    const run_exe = b.addRunArtifact(main_exe);
    run_step.dependOn(&run_exe.step);
}
