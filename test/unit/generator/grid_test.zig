const std = @import("std");
const testing = std.testing;
const headwind = @import("headwind");

const grid = headwind.grid;
const CSSGenerator = headwind.CSSGenerator;
const class_parser = headwind.class_parser;

// ============================================================================
// Grid Template Columns Tests
// ============================================================================

test "grid template columns count" {
    const allocator = testing.allocator;

    const counts = [_][]const u8{
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12",
    };

    for (counts) |count| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "grid-cols-{s}", .{count});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridTemplateColumns(&generator, &parsed, count);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-template-columns") != null);
    }
}

test "grid template columns special" {
    const allocator = testing.allocator;

    const special = [_][]const u8{ "none", "subgrid" };

    for (special) |value| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "grid-cols-{s}", .{value});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridTemplateColumns(&generator, &parsed, value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-template-columns") != null);
    }
}

// ============================================================================
// Grid Template Rows Tests
// ============================================================================

test "grid template rows count" {
    const allocator = testing.allocator;

    const counts = [_][]const u8{ "1", "2", "3", "4", "5", "6" };

    for (counts) |count| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "grid-rows-{s}", .{count});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridTemplateRows(&generator, &parsed, count);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-template-rows") != null);
    }
}

test "grid template rows special" {
    const allocator = testing.allocator;

    const special = [_][]const u8{ "none", "subgrid" };

    for (special) |value| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "grid-rows-{s}", .{value});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridTemplateRows(&generator, &parsed, value);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-template-rows") != null);
    }
}

// ============================================================================
// Grid Column Span Tests
// ============================================================================

test "grid column span" {
    const allocator = testing.allocator;

    const spans = [_][]const u8{
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12",
        "auto", "full",
    };

    for (spans) |span| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "col-span-{s}", .{span});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridColumnSpan(&generator, &parsed, span);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-column") != null);
    }
}

// ============================================================================
// Grid Column Start/End Tests
// ============================================================================

test "grid column start" {
    const allocator = testing.allocator;

    const starts = [_][]const u8{
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "auto",
    };

    for (starts) |start| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "col-start-{s}", .{start});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridColumnStart(&generator, &parsed, start);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-column-start") != null);
    }
}

test "grid column end" {
    const allocator = testing.allocator;

    const ends = [_][]const u8{
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "auto",
    };

    for (ends) |end| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "col-end-{s}", .{end});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridColumnEnd(&generator, &parsed, end);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-column-end") != null);
    }
}

// ============================================================================
// Grid Row Span Tests
// ============================================================================

test "grid row span" {
    const allocator = testing.allocator;

    const spans = [_][]const u8{
        "1", "2", "3", "4", "5", "6", "auto", "full",
    };

    for (spans) |span| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "row-span-{s}", .{span});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridRowSpan(&generator, &parsed, span);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-row") != null);
    }
}

// ============================================================================
// Grid Row Start/End Tests
// ============================================================================

test "grid row start" {
    const allocator = testing.allocator;

    const starts = [_][]const u8{ "1", "2", "3", "4", "5", "6", "7", "auto" };

    for (starts) |start| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "row-start-{s}", .{start});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridRowStart(&generator, &parsed, start);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-row-start") != null);
    }
}

test "grid row end" {
    const allocator = testing.allocator;

    const ends = [_][]const u8{ "1", "2", "3", "4", "5", "6", "7", "auto" };

    for (ends) |end| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "row-end-{s}", .{end});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridRowEnd(&generator, &parsed, end);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-row-end") != null);
    }
}

// ============================================================================
// Grid Auto Flow Tests
// ============================================================================

test "grid auto flow values" {
    const allocator = testing.allocator;

    const flows = [_][]const u8{
        "row", "col", "dense", "row-dense", "col-dense",
    };

    for (flows) |flow| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "grid-flow-{s}", .{flow});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridAutoFlow(&generator, &parsed, flow);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-auto-flow") != null);
    }
}

// ============================================================================
// Grid Auto Columns/Rows Tests
// ============================================================================

test "grid auto columns" {
    const allocator = testing.allocator;

    const autos = [_][]const u8{ "auto", "min", "max", "fr" };

    for (autos) |auto| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "auto-cols-{s}", .{auto});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridAutoColumns(&generator, &parsed, auto);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-auto-columns") != null);
    }
}

test "grid auto rows" {
    const allocator = testing.allocator;

    const autos = [_][]const u8{ "auto", "min", "max", "fr" };

    for (autos) |auto| {
        var generator = CSSGenerator.init(allocator);
        defer generator.deinit();

        const class_name = try std.fmt.allocPrint(allocator, "auto-rows-{s}", .{auto});
        defer allocator.free(class_name);

        var parsed = try class_parser.parseClass(allocator, class_name);
        defer parsed.deinit(allocator);

        try grid.generateGridAutoRows(&generator, &parsed, auto);

        const css = try generator.generate();
        defer allocator.free(css);

        try testing.expect(std.mem.indexOf(u8, css, "grid-auto-rows") != null);
    }
}
