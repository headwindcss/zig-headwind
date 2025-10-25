// Test runner that imports all test files
const std = @import("std");

// Import all test modules
test {
    // ====================
    // Phase 1: Core Functionality Tests
    // ====================
    _ = @import("unit/parser/class_parser_test.zig");
    _ = @import("unit/parser/arbitrary_value_test.zig");
    _ = @import("unit/generator/colors_test.zig");
    _ = @import("unit/generator/typography_test.zig");
    _ = @import("unit/generator/css_generator_test.zig");

    // ====================
    // Phase 2: Essential Generator Tests
    // ====================
    _ = @import("unit/generator/backgrounds_test.zig");
    _ = @import("unit/generator/borders_test.zig");
    _ = @import("unit/generator/sizing_test.zig");
    _ = @import("unit/generator/spacing_test.zig");
    _ = @import("unit/generator/layout_test.zig");

    // ====================
    // Phase 3: Advanced Generator Tests
    // ====================
    _ = @import("unit/generator/flexbox_test.zig");
    _ = @import("unit/generator/grid_test.zig");
    _ = @import("unit/generator/effects_test.zig");
    _ = @import("unit/generator/transforms_test.zig");
    _ = @import("unit/generator/filters_test.zig");
    _ = @import("unit/generator/transitions_animations_test.zig");

    // ====================
    // Phase 4: Integration Tests
    // ====================
    _ = @import("integration/parser_generator_test.zig");

    // ====================
    // Phase 5: End-to-End Tests
    // ====================
    _ = @import("e2e/complete_workflow_test.zig");
}
