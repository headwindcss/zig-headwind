/**
 * Cache Performance Test
 * Specifically tests cold vs warm build performance
 */

import { bench, group, run } from 'mitata';
import { execSync } from 'child_process';
import { writeFileSync, mkdirSync, rmSync } from 'fs';

// Create temp directory
mkdirSync('temp', { recursive: true });

const TEST_HTML = `
<!DOCTYPE html>
<html>
<head><title>Cache Test</title></head>
<body>
  <div class="bg-blue-500 text-white p-4 m-2 rounded-lg shadow-md">
    <h1 class="text-3xl font-bold mb-4">Test</h1>
    <div class="flex items-center justify-between gap-4">
      <button class="px-6 py-2 bg-green-500 hover:bg-green-600 rounded-md">
        Click
      </button>
    </div>
  </div>
</body>
</html>
`;

writeFileSync('temp/cache-test.html', TEST_HTML);

console.log('🧪 Testing cache performance...\n');

// First, do a single build to populate cache
console.log('Populating cache with initial build...');
execSync('../zig-out/bin/headwind build temp/cache-test.html -o temp/cache-test.css', {
  stdio: 'pipe',
});
console.log('Cache populated.\n');

group('Cache Performance Test', () => {
  bench('Build (cache should be warm)', () => {
    execSync('../zig-out/bin/headwind build temp/cache-test.html -o temp/cache-test-out.css', {
      stdio: 'pipe',
    });
  });
});

await run({
  units: false,
  silent: false,
  avg: true,
  json: false,
  colors: true,
  min_max: true,
  percentiles: true,
});

console.log('\n✅ Cache test complete!');

// Cleanup
rmSync('temp', { recursive: true, force: true });
