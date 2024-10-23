const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "thorvg-zig-example",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const thorvg_dep = b.dependency("thorvg", .{
        .target = target,
        .optimize = optimize,
    });
    const thorvg = thorvg_dep.artifact("thorvg");
    exe.linkLibrary(thorvg);
    exe.installLibraryHeaders(thorvg);

    const upstream_dep = thorvg_dep.builder.dependency("thorvg", .{});
    b.getInstallStep().dependOn(&b.addInstallFile(
        upstream_dep.path("examples/resources/svg/tiger.svg"),
        "tiger.svg",
    ).step);
    b.getInstallStep().dependOn(&b.addInstallFile(
        upstream_dep.path("examples/resources/lottie/sample.json"),
        "sample.json",
    ).step);
    b.getInstallStep().dependOn(&b.addInstallFile(
        upstream_dep.path("examples/resources/font/SentyCloud.ttf"),
        "SentyCloud.ttf",
    ).step);

    const sdl = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    }).artifact("SDL2");
    exe.linkLibrary(sdl);
    exe.installLibraryHeaders(sdl);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
