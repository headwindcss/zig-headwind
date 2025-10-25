// Test runner that imports all test files
const std = @import("std");

// Import all test modules
test {
    _ = @import("unit/parser/class_parser_test.zig");
    _ = @import("unit/generator/colors_test.zig");
    _ = @import("unit/generator/typography_test.zig");
    _ = @import("unit/generator/css_generator_test.zig");
    // More test imports will be added here as we create them
    // _ = @import("unit/parser/arbitrary_value_test.zig");
    // etc.
}
