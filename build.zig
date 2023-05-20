const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var translate_step = b.addTranslateC(.{
        .source_file = .{ .path = "./freetype.h" },
        .target = target,
        .optimize = optimize,
    });

    translate_step.addIncludeDir(b.pathFromRoot("freetype/include"));

    _ = b.addModule("freetype", .{
        .source_file = .{ .generated = &translate_step.output_file },
    });

    const root_dir = b.pathFromRoot("freetype");
    var lib = b.addStaticLibrary(.{
        .name = "freetype",
        .target = target,
        .optimize = optimize,
    });

    const sources = &[_][]const u8{
        "src/autofit/autofit.c",
        "src/base/ftbase.c",
        "src/base/ftbbox.c",
        "src/base/ftbdf.c",
        "src/base/ftbitmap.c",
        "src/base/ftcid.c",
        "src/base/ftfstype.c",
        "src/base/ftgasp.c",
        "src/base/ftglyph.c",
        "src/base/ftgxval.c",
        "src/base/ftinit.c",
        "src/base/ftmm.c",
        "src/base/ftotval.c",
        "src/base/ftpatent.c",
        "src/base/ftpfr.c",
        "src/base/ftstroke.c",
        "src/base/ftsynth.c",
        "src/base/ftsystem.c",
        "src/base/fttype1.c",
        "src/base/ftwinfnt.c",
        "src/bdf/bdf.c",
        "src/bzip2/ftbzip2.c",
        "src/cache/ftcache.c",
        "src/cff/cff.c",
        "src/cid/type1cid.c",
        "src/gzip/ftgzip.c",
        "src/lzw/ftlzw.c",
        "src/pcf/pcf.c",
        "src/pfr/pfr.c",
        "src/psaux/psaux.c",
        "src/pshinter/pshinter.c",
        "src/psnames/psnames.c",
        "src/raster/raster.c",
        "src/sdf/sdf.c",
        "src/sfnt/sfnt.c",
        "src/smooth/smooth.c",
        "src/svg/svg.c",
        "src/truetype/truetype.c",
        "src/type1/type1.c",
        "src/type42/type42.c",
        "src/winfonts/winfnt.c",
    };

    const additional = switch (target.os_tag orelse b.host.target.os.tag) {
        .windows => &[_][]const u8{"builds/windows/ftdebug.c"},
        else => &[_][]const u8{"src/base/ftdebug.c"},
    };

    const full_list = sources ++ additional;

    var absolute_sources = std.ArrayList([]const u8).initCapacity(b.allocator, full_list.len) catch unreachable;
    defer absolute_sources.deinit();

    inline for (full_list) |path| {
        const resolved = std.fs.path.join(b.allocator, &[_][]const u8{ root_dir, path }) catch unreachable;
        absolute_sources.appendAssumeCapacity(resolved);
    }

    lib.addCSourceFiles(absolute_sources.items, &[_][]const u8{
        "-DFT2_BUILD_LIBRARY",
    });

    lib.addIncludePath(b.pathFromRoot("freetype/include"));
    lib.linkLibC();

    b.installArtifact(lib);
}
