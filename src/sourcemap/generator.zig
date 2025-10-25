const std = @import("std");
const types = @import("../core/types.zig");

/// Source Map v3 generator
/// Implements the Source Map v3 specification for CSS output
/// https://sourcemaps.info/spec.html
pub const SourceMapGenerator = struct {
    allocator: std.mem.Allocator,
    file: []const u8, // Output CSS file name
    source_root: ?[]const u8,
    sources: std.ArrayList([]const u8), // List of source files
    sources_content: ?std.ArrayList([]const u8), // Optional source content
    names: std.ArrayList([]const u8), // Symbol names
    mappings: std.ArrayList(Mapping), // Line/column mappings

    pub const Mapping = struct {
        /// Generated line number (0-indexed)
        generated_line: u32,
        /// Generated column number (0-indexed)
        generated_column: u32,
        /// Source file index
        source_index: u32,
        /// Original line number (0-indexed)
        original_line: u32,
        /// Original column number (0-indexed)
        original_column: u32,
        /// Optional name index
        name_index: ?u32 = null,
    };

    pub fn init(allocator: std.mem.Allocator, file: []const u8) SourceMapGenerator {
        return .{
            .allocator = allocator,
            .file = file,
            .source_root = null,
            .sources = std.ArrayList([]const u8).init(allocator),
            .sources_content = null,
            .names = std.ArrayList([]const u8).init(allocator),
            .mappings = std.ArrayList(Mapping).init(allocator),
        };
    }

    pub fn deinit(self: *SourceMapGenerator) void {
        for (self.sources.items) |source| {
            self.allocator.free(source);
        }
        self.sources.deinit();

        if (self.sources_content) |*content| {
            for (content.items) |c| {
                self.allocator.free(c);
            }
            content.deinit();
        }

        for (self.names.items) |name| {
            self.allocator.free(name);
        }
        self.names.deinit();
        self.mappings.deinit();
    }

    /// Add a source file
    pub fn addSource(self: *SourceMapGenerator, source_file: []const u8) !u32 {
        // Check if source already exists
        for (self.sources.items, 0..) |source, i| {
            if (std.mem.eql(u8, source, source_file)) {
                return @intCast(i);
            }
        }

        const index: u32 = @intCast(self.sources.items.len);
        try self.sources.append(try self.allocator.dupe(u8, source_file));
        return index;
    }

    /// Add a mapping from generated CSS to source location
    pub fn addMapping(
        self: *SourceMapGenerator,
        generated_line: u32,
        generated_column: u32,
        source_file: []const u8,
        original_line: u32,
        original_column: u32,
    ) !void {
        const source_index = try self.addSource(source_file);

        try self.mappings.append(.{
            .generated_line = generated_line,
            .generated_column = generated_column,
            .source_index = source_index,
            .original_line = original_line,
            .original_column = original_column,
        });
    }

    /// Generate the source map as JSON
    pub fn generate(self: *SourceMapGenerator) ![]const u8 {
        var output = std.ArrayList(u8).init(self.allocator);
        errdefer output.deinit();

        const writer = output.writer();

        // Start JSON object
        try writer.writeAll("{\n");

        // Version
        try writer.writeAll("  \"version\": 3,\n");

        // File
        try writer.print("  \"file\": \"{s}\",\n", .{self.file});

        // Source root (optional)
        if (self.source_root) |root| {
            try writer.print("  \"sourceRoot\": \"{s}\",\n", .{root});
        }

        // Sources array
        try writer.writeAll("  \"sources\": [");
        for (self.sources.items, 0..) |source, i| {
            if (i > 0) try writer.writeAll(", ");
            try writer.print("\"{s}\"", .{source});
        }
        try writer.writeAll("],\n");

        // Sources content (optional)
        if (self.sources_content) |content| {
            try writer.writeAll("  \"sourcesContent\": [");
            for (content.items, 0..) |c, i| {
                if (i > 0) try writer.writeAll(", ");
                try writer.print("\"{s}\"", .{escapeJson(c)});
            }
            try writer.writeAll("],\n");
        }

        // Names array (usually empty for CSS)
        try writer.writeAll("  \"names\": [],\n");

        // Mappings (VLQ encoded)
        try writer.writeAll("  \"mappings\": \"");
        try self.encodeMappings(writer);
        try writer.writeAll("\"\n");

        // End JSON object
        try writer.writeAll("}\n");

        return output.toOwnedSlice();
    }

    /// Encode mappings using VLQ (Variable Length Quantity) encoding
    fn encodeMappings(self: *SourceMapGenerator, writer: anytype) !void {
        // Sort mappings by generated position
        std.mem.sort(Mapping, self.mappings.items, {}, mappingLessThan);

        var prev_generated_line: u32 = 0;
        var prev_generated_column: u32 = 0;
        var prev_source_index: u32 = 0;
        var prev_original_line: u32 = 0;
        var prev_original_column: u32 = 0;

        for (self.mappings.items) |mapping| {
            // Add semicolons for new lines
            while (prev_generated_line < mapping.generated_line) {
                try writer.writeAll(";");
                prev_generated_line += 1;
                prev_generated_column = 0;
            }

            if (prev_generated_column > 0) {
                try writer.writeAll(",");
            }

            // Encode the mapping (relative to previous values)
            // Field 1: Generated column delta
            try encodeVlq(writer, @as(i32, @intCast(mapping.generated_column)) - @as(i32, @intCast(prev_generated_column)));

            // Field 2: Source file index delta
            try encodeVlq(writer, @as(i32, @intCast(mapping.source_index)) - @as(i32, @intCast(prev_source_index)));

            // Field 3: Original line delta
            try encodeVlq(writer, @as(i32, @intCast(mapping.original_line)) - @as(i32, @intCast(prev_original_line)));

            // Field 4: Original column delta
            try encodeVlq(writer, @as(i32, @intCast(mapping.original_column)) - @as(i32, @intCast(prev_original_column)));

            // Field 5: Name index (optional - we don't use it for CSS)

            // Update previous values
            prev_generated_column = mapping.generated_column;
            prev_source_index = mapping.source_index;
            prev_original_line = mapping.original_line;
            prev_original_column = mapping.original_column;
        }
    }

    fn mappingLessThan(_: void, a: Mapping, b: Mapping) bool {
        if (a.generated_line != b.generated_line) {
            return a.generated_line < b.generated_line;
        }
        return a.generated_column < b.generated_column;
    }
};

/// Encode an integer using VLQ (Variable Length Quantity) Base64
fn encodeVlq(writer: anytype, value: i32) !void {
    var vlq: u32 = if (value < 0)
        (@as(u32, @intCast(-value)) << 1) | 1
    else
        @as(u32, @intCast(value)) << 1;

    while (true) {
        var digit = vlq & 0x1F;
        vlq >>= 5;

        if (vlq > 0) {
            digit |= 0x20; // Continuation bit
        }

        try writer.writeByte(base64Encode(digit));

        if (vlq == 0) break;
    }
}

/// Base64 encoding for VLQ
fn base64Encode(value: u32) u8 {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    return chars[value];
}

/// Escape JSON string
fn escapeJson(str: []const u8) []const u8 {
    // Simple implementation - in production would need proper escaping
    return str;
}

/// Helper to add source map comment to CSS
pub fn addSourceMapComment(allocator: std.mem.Allocator, css: []const u8, map_file: []const u8) ![]const u8 {
    return std.fmt.allocPrint(
        allocator,
        "{s}\n/*# sourceMappingURL={s} */\n",
        .{ css, map_file },
    );
}

// ============================================================================
// Tests
// ============================================================================

test "source map basic generation" {
    const allocator = std.testing.allocator;

    var gen = SourceMapGenerator.init(allocator, "output.css");
    defer gen.deinit();

    // Add a mapping: CSS line 0, col 0 came from src/index.html line 10, col 5
    try gen.addMapping(0, 0, "src/index.html", 10, 5);

    const json = try gen.generate();
    defer allocator.free(json);

    try std.testing.expect(std.mem.indexOf(u8, json, "\"version\": 3") != null);
    try std.testing.expect(std.mem.indexOf(u8, json, "\"file\": \"output.css\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, json, "src/index.html") != null);
}

test "VLQ encoding" {
    const allocator = std.testing.allocator;
    var output = std.ArrayList(u8).init(allocator);
    defer output.deinit();

    // Test encoding 0
    try encodeVlq(output.writer(), 0);
    try std.testing.expectEqualStrings("A", output.items);

    output.clearRetainingCapacity();

    // Test encoding 1
    try encodeVlq(output.writer(), 1);
    try std.testing.expectEqualStrings("C", output.items);

    output.clearRetainingCapacity();

    // Test encoding -1
    try encodeVlq(output.writer(), -1);
    try std.testing.expectEqualStrings("D", output.items);
}

test "multiple sources" {
    const allocator = std.testing.allocator;

    var gen = SourceMapGenerator.init(allocator, "output.css");
    defer gen.deinit();

    try gen.addMapping(0, 0, "src/index.html", 10, 5);
    try gen.addMapping(1, 0, "src/app.jsx", 20, 10);
    try gen.addMapping(2, 0, "src/index.html", 11, 5);

    try std.testing.expectEqual(@as(usize, 2), gen.sources.items.len);
    try std.testing.expectEqual(@as(usize, 3), gen.mappings.items.len);
}
