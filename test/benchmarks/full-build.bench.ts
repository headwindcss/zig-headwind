/**
 * Full build benchmarks
 * Tests complete end-to-end build performance
 */

import { bench, group, run } from 'mitata';
import { execSync } from 'child_process';
import { writeFileSync, mkdirSync } from 'fs';

// Create test project structure
mkdirSync('temp/src', { recursive: true });

// Small project
const smallProject = `
<!DOCTYPE html>
<html>
<body>
  <div class="bg-blue-500 text-white p-4 rounded-lg">Hello World</div>
</body>
</html>
`;
writeFileSync('temp/src/small.html', smallProject);

// Medium project (realistic landing page)
const mediumProject = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Medium Project</title>
</head>
<body>
  <nav class="bg-white shadow-lg">
    <div class="container mx-auto px-4 py-4 flex items-center justify-between">
      <div class="text-2xl font-bold text-blue-600">Logo</div>
      <div class="hidden md:flex space-x-8">
        <a href="#" class="text-gray-700 hover:text-blue-600 transition-colors">Home</a>
        <a href="#" class="text-gray-700 hover:text-blue-600 transition-colors">About</a>
        <a href="#" class="text-gray-700 hover:text-blue-600 transition-colors">Contact</a>
      </div>
    </div>
  </nav>

  <main class="container mx-auto px-4 py-12">
    <section class="text-center mb-16">
      <h1 class="text-5xl font-bold text-gray-900 mb-4">Welcome</h1>
      <p class="text-xl text-gray-600 max-w-2xl mx-auto">
        This is a medium-sized test project with realistic class usage.
      </p>
    </section>

    <section class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
      ${Array(6).fill(null).map((_, i) => `
        <div class="bg-white rounded-lg shadow-xl p-6 hover:shadow-2xl transition-shadow">
          <div class="bg-blue-500 rounded-full w-16 h-16 flex items-center justify-center mb-4">
            <span class="text-white text-2xl font-bold">${i + 1}</span>
          </div>
          <h3 class="text-xl font-semibold mb-2 text-gray-900">Feature ${i + 1}</h3>
          <p class="text-gray-600">Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
        </div>
      `).join('')}
    </section>
  </main>

  <footer class="bg-gray-900 text-white py-8 mt-16">
    <div class="container mx-auto px-4 text-center">
      <p class="text-gray-400">© 2025 Medium Project. All rights reserved.</p>
    </div>
  </footer>
</body>
</html>
`;
writeFileSync('temp/src/medium.html', mediumProject);

// Large project (complex dashboard)
const largeProject = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Large Project</title>
</head>
<body class="bg-gray-100">
  <div class="flex h-screen">
    <!-- Sidebar -->
    <aside class="w-64 bg-gray-900 text-white flex flex-col">
      <div class="p-4 text-2xl font-bold border-b border-gray-800">Dashboard</div>
      <nav class="flex-1 p-4 space-y-2">
        ${Array(10).fill(null).map((_, i) => `
          <a href="#" class="block px-4 py-2 rounded-lg hover:bg-gray-800 transition-colors">
            Menu Item ${i + 1}
          </a>
        `).join('')}
      </nav>
    </aside>

    <!-- Main content -->
    <div class="flex-1 flex flex-col overflow-hidden">
      <!-- Header -->
      <header class="bg-white shadow-md px-6 py-4 flex items-center justify-between">
        <h1 class="text-2xl font-bold text-gray-900">Dashboard</h1>
        <div class="flex items-center space-x-4">
          <button class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors">
            New Item
          </button>
          <div class="w-10 h-10 bg-gray-300 rounded-full"></div>
        </div>
      </header>

      <!-- Content area -->
      <main class="flex-1 overflow-auto p-6">
        <!-- Stats -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          ${Array(4).fill(null).map((_, i) => `
            <div class="bg-white rounded-lg shadow-lg p-6">
              <div class="text-sm text-gray-600 mb-2">Metric ${i + 1}</div>
              <div class="text-3xl font-bold text-gray-900">${(i + 1) * 1000}</div>
              <div class="text-sm text-green-500 mt-2">+12%</div>
            </div>
          `).join('')}
        </div>

        <!-- Charts -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <div class="bg-white rounded-lg shadow-lg p-6">
            <h2 class="text-xl font-semibold mb-4">Chart 1</h2>
            <div class="h-64 bg-gray-200 rounded"></div>
          </div>
          <div class="bg-white rounded-lg shadow-lg p-6">
            <h2 class="text-xl font-semibold mb-4">Chart 2</h2>
            <div class="h-64 bg-gray-200 rounded"></div>
          </div>
        </div>

        <!-- Table -->
        <div class="bg-white rounded-lg shadow-lg overflow-hidden">
          <table class="w-full">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              ${Array(20).fill(null).map((_, i) => `
                <tr class="hover:bg-gray-50 transition-colors">
                  <td class="px-6 py-4 text-sm text-gray-900">Item ${i + 1}</td>
                  <td class="px-6 py-4">
                    <span class="px-2 py-1 text-xs rounded-full ${i % 2 ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}">
                      ${i % 2 ? 'Active' : 'Pending'}
                    </span>
                  </td>
                  <td class="px-6 py-4 text-sm text-gray-600">2025-01-${i + 1}</td>
                  <td class="px-6 py-4">
                    <button class="text-blue-600 hover:text-blue-800 text-sm font-medium">Edit</button>
                  </td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      </main>
    </div>
  </div>
</body>
</html>
`;
writeFileSync('temp/src/large.html', largeProject);

group('Full Build - Project Size', () => {
  bench('Small project (1 file, ~10 classes)', () => {
    execSync('../zig-out/bin/headwind build temp/src/small.html -o temp/small.css', {
      stdio: 'pipe',
    });
  });

  bench('Medium project (1 file, ~100 classes)', () => {
    execSync('../zig-out/bin/headwind build temp/src/medium.html -o temp/medium.css', {
      stdio: 'pipe',
    });
  });

  bench('Large project (1 file, ~500 classes)', () => {
    execSync('../zig-out/bin/headwind build temp/src/large.html -o temp/large.css', {
      stdio: 'pipe',
    });
  });
});

group('Full Build - Optimization Levels', () => {
  bench('Development build (no minification)', () => {
    execSync('../zig-out/bin/headwind build temp/src/medium.html -o temp/dev.css', {
      stdio: 'pipe',
    });
  });

  bench('Production build (minified)', () => {
    execSync('../zig-out/bin/headwind build temp/src/medium.html -o temp/prod.css --minify', {
      stdio: 'pipe',
    });
  });
});

group('Full Build - Cache Performance', () => {
  bench('Cold build (no cache)', () => {
    execSync('../zig-out/bin/headwind build temp/src/medium.html -o temp/output.css --no-cache', {
      stdio: 'pipe',
    });
  });

  bench('Warm build (with cache)', () => {
    // First build to populate cache
    execSync('../zig-out/bin/headwind build temp/src/medium.html -o temp/output.css', {
      stdio: 'pipe',
    });
    // Second build (measured)
    execSync('../zig-out/bin/headwind build temp/src/medium.html -o temp/output.css', {
      stdio: 'pipe',
    });
  });
});

group('Full Build - Watch Mode Simulation', () => {
  bench('Incremental rebuild', () => {
    // Simulate file change
    writeFileSync('temp/src/medium.html', mediumProject + '\n<!-- changed -->');
    execSync('../zig-out/bin/headwind build temp/src/medium.html -o temp/output.css --incremental', {
      stdio: 'pipe',
    });
  });
});

console.log('🏗️  Running full build benchmarks...\n');
await run({
  units: false,
  silent: false,
  avg: true,
  json: false,
  colors: true,
  min_max: true,
  percentiles: true,
});

console.log('\n✅ Full build benchmarks complete!');
