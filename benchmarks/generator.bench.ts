/**
 * CSS Generator benchmarks
 * Tests the performance of CSS generation for different utility types
 */

import { bench, group, run } from 'mitata';
import { execSync } from 'child_process';
import { writeFileSync, mkdirSync, rmSync } from 'fs';

// Create temp directory
mkdirSync('temp', { recursive: true });

// Test sets for different utility categories
const utilities = {
  colors: 'bg-blue-500 text-red-500 border-green-500 ring-purple-500',
  typography: 'text-3xl font-bold leading-relaxed tracking-wide',
  spacing: 'p-4 m-2 px-6 py-8 mx-auto space-x-4',
  sizing: 'w-full h-screen max-w-7xl min-h-0',
  layout: 'flex items-center justify-between gap-4 grid grid-cols-3',
  borders: 'border-2 border-solid rounded-lg shadow-xl ring-2',
  effects: 'opacity-50 blur-sm brightness-150 saturate-200',
  transforms: 'scale-110 rotate-45 translate-x-4 skew-y-6',
  transitions: 'transition-all duration-300 ease-in-out delay-100',
  responsive: 'sm:text-sm md:text-base lg:text-lg xl:text-xl',
  darkMode: 'dark:bg-gray-900 dark:text-white dark:border-gray-700',
  all: [
    'bg-blue-500', 'text-white', 'p-4', 'rounded-lg', 'shadow-md',
    'hover:bg-blue-600', 'focus:ring-2', 'transition-colors',
    'md:text-lg', 'lg:p-6', 'dark:bg-gray-800', 'flex', 'items-center',
  ].join(' '),
};

function createTestHTML(classes: string): string {
  return `<!DOCTYPE html><html><body><div class="${classes}"></div></body></html>`;
}

group('Generator - Color Utilities', () => {
  bench('Generate color CSS', () => {
    writeFileSync('temp/colors.html', createTestHTML(utilities.colors));
    execSync('../zig-out/bin/headwind build temp/colors.html -o temp/colors.css', {
      stdio: 'pipe',
    });
  });
});

group('Generator - Typography Utilities', () => {
  bench('Generate typography CSS', () => {
    writeFileSync('temp/typography.html', createTestHTML(utilities.typography));
    execSync('../zig-out/bin/headwind build temp/typography.html -o temp/typography.css', {
      stdio: 'pipe',
    });
  });
});

group('Generator - Spacing Utilities', () => {
  bench('Generate spacing CSS', () => {
    writeFileSync('temp/spacing.html', createTestHTML(utilities.spacing));
    execSync('../zig-out/bin/headwind build temp/spacing.html -o temp/spacing.css', {
      stdio: 'pipe',
    });
  });
});

group('Generator - Sizing Utilities', () => {
  bench('Generate sizing CSS', () => {
    writeFileSync('temp/sizing.html', createTestHTML(utilities.sizing));
    execSync('../zig-out/bin/headwind build temp/sizing.html -o temp/sizing.css', {
      stdio: 'pipe',
    });
  });
});

group('Generator - Layout Utilities', () => {
  bench('Generate layout CSS (flexbox + grid)', () => {
    writeFileSync('temp/layout.html', createTestHTML(utilities.layout));
    execSync('../zig-out/bin/headwind build temp/layout.html -o temp/layout.css', {
      stdio: 'pipe',
    });
  });
});

group('Generator - Border Utilities', () => {
  bench('Generate border CSS', () => {
    writeFileSync('temp/borders.html', createTestHTML(utilities.borders));
    execSync('../zig-out/bin/headwind build temp/borders.html -o temp/borders.css', {
      stdio: 'pipe',
    });
  });
});

group('Generator - Effects & Filters', () => {
  bench('Generate effects CSS', () => {
    writeFileSync('temp/effects.html', createTestHTML(utilities.effects));
    execSync('../zig-out/bin/headwind build temp/effects.html -o temp/effects.css', {
      stdio: 'pipe',
    });
  });
});

group('Generator - Transforms', () => {
  bench('Generate transform CSS', () => {
    writeFileSync('temp/transforms.html', createTestHTML(utilities.transforms));
    execSync('../zig-out/bin/headwind build temp/transforms.html -o temp/transforms.css', {
      stdio: 'pipe',
    });
  });
});

group('Generator - Transitions & Animations', () => {
  bench('Generate transition CSS', () => {
    writeFileSync('temp/transitions.html', createTestHTML(utilities.transitions));
    execSync('../zig-out/bin/headwind build temp/transitions.html -o temp/transitions.css', {
      stdio: 'pipe',
    });
  });
});

group('Generator - Responsive Variants', () => {
  bench('Generate responsive CSS', () => {
    writeFileSync('temp/responsive.html', createTestHTML(utilities.responsive));
    execSync('../zig-out/bin/headwind build temp/responsive.html -o temp/responsive.css', {
      stdio: 'pipe',
    });
  });
});

group('Generator - Dark Mode', () => {
  bench('Generate dark mode CSS', () => {
    writeFileSync('temp/darkmode.html', createTestHTML(utilities.darkMode));
    execSync('../zig-out/bin/headwind build temp/darkmode.html -o temp/darkmode.css', {
      stdio: 'pipe',
    });
  });
});

group('Generator - Complete Build', () => {
  bench('Generate complete CSS (all utilities)', () => {
    writeFileSync('temp/all.html', createTestHTML(utilities.all));
    execSync('../zig-out/bin/headwind build temp/all.html -o temp/all.css', {
      stdio: 'pipe',
    });
  });
});

console.log('🎨 Running CSS generator benchmarks...\n');
await run({
  units: false,
  silent: false,
  avg: true,
  json: false,
  colors: true,
  min_max: true,
  percentiles: true,
});

console.log('\n✅ Generator benchmarks complete!');

// Cleanup
rmSync('temp', { recursive: true, force: true });
