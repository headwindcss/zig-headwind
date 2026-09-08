#!/bin/bash
cd /Users/chrisbreuer/Code/zig-css
echo "Testing SIMD module..."
zig test src/utils/simd.zig > /tmp/zig_simd_test.log 2>&1
EXIT_CODE=$?
echo "Exit code: $EXIT_CODE"
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ SIMD tests passed!"
else
    echo "❌ SIMD tests failed. Showing errors:"
    cat /tmp/zig_simd_test.log | head -50
fi
exit $EXIT_CODE
