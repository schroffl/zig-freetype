Basic Zig bindings for [FreeType](https://freetype.org). This does not contain any actual code. It just provides an easy way to integrate the FreeType library into a Zig project.

#### Example

To use the library you first need to add the dependency to your `build.zig.zon` file:

```
.{
    .name = "zig-freetype-example",
    .version = "0.1.0",
    .dependencies = .{
        .freetype = .{
            .url = "https://github.com/schroffl/zig-freetype/archive/2b431fc44f0a1f76a23f2db5432a00f7d862cca7.tar.gz",
            .hash = "1220136cb7a8877bf161e68ae1c79415c9401c28ba86bd5cf0b596e3276935602e4f",
        },
    },
}
```

In your `build.zig` you need to add the translated headers as a module a link the library:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
            .name = "freetype-test",
            .root_source_file = .{ .path = "src/main.zig" },
            .target = target,
            .optimize = optimize,
            });

    // Add the freetype module and link the library
    {
        const ft_dep = b.dependency("freetype", .{
                .optimize = optimize,
                .target = target,
                });

        exe.addModule("freetype", ft_dep.module("freetype"));
        exe.linkLibrary(ft_dep.artifact("freetype"));
    }

    b.installArtifact(exe);
}
```

You can now use the library like this:
```zig
const std = @import("std");
const freetype = @import("freetype");

pub fn main() !void {
    const font_bytes = @embedFile("cour.ttf");

    var lib: freetype.FT_Library = undefined;
    var face: freetype.FT_Face = undefined;

    if (freetype.FT_Init_FreeType(&lib) != 0) {
        return error.FreeTypeInitFailed;
    }

    if (freetype.FT_New_Memory_Face(lib, font_bytes, font_bytes.len, 0, &face) != 0) {
        return error.FailedToLoadFont;
    }

    _ = freetype.FT_Set_Pixel_Sizes(face, 0, 64);

    const char = 'a';
    const glyph_index = freetype.FT_Get_Char_Index(face, char);
    const load_glyph_result = freetype.FT_Load_Glyph(face, glyph_index, freetype.FT_LOAD_DEFAULT);
    std.debug.assert(load_glyph_result == 0);

    const bitmap = face.*.glyph.*.bitmap;
    std.log.debug("Width: {}, Height: {}", .{bitmap.width, bitmap.rows});
}
```
