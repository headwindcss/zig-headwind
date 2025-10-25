/**
 * CSS Generator benchmarks
 * Tests the performance of CSS generation for different utility types
 */

import { bench, group, run } from 'mitata';
import { execSync } from 'child_process';

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

group('Generator - Color Utilities', () => {
  bench('Generate color CSS', () => {
    execSync(`echo "${utilities.colors}" | ../zig-out/bin/headwind build --stdout`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Generator - Typography Utilities', () => {
  bench('Generate typography CSS', () => {
    execSync(`echo "${utilities.typography}" | ../zig-out/bin/headwind build --stdout`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Generator - Spacing Utilities', () => {
  bench('Generate spacing CSS', () => {
    execSync(`echo "${utilities.spacing}" | ../zig-out/bin/headwind build --stdout`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Generator - Sizing Utilities', () => {
  bench('Generate sizing CSS', () => {
    execSync(`echo "${utilities.sizing}" | ../zig-out/bin/headwind build --stdout`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Generator - Layout Utilities', () => {
  bench('Generate layout CSS (flexbox + grid)', () => {
    execSync(`echo "${utilities.layout}" | ../zig-out/bin/headwind build --stdout`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Generator - Border Utilities', () => {
  bench('Generate border CSS', () => {
    execSync(`echo "${utilities.borders}" | ../zig-out/bin/headwind build --stdout`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Generator - Effects & Filters', () => {
  bench('Generate effects CSS', () => {
    execSync(`echo "${utilities.effects}" | ../zig-out/bin/headwind build --stdout`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Generator - Transforms', () => {
  bench('Generate transform CSS', () => {
    execSync(`echo "${utilities.transforms}" | ../zig-out/bin/headwind build --stdout`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Generator - Transitions & Animations', () => {
  bench('Generate transition CSS', () => {
    execSync(`echo "${utilities.transitions}" | ../zig-out/bin/headwind build --stdout`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Generator - Responsive Variants', () => {
  bench('Generate responsive CSS', () => {
    execSync(`echo "${utilities.responsive}" | ../zig-out/bin/headwind build --stdout`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Generator - Dark Mode', () => {
  bench('Generate dark mode CSS', () => {
    execSync(`echo "${utilities.darkMode}" | ../zig-out/bin/headwind build --stdout`, {
      encoding: 'utf-8',
      stdio: 'pipe',
    });
  });
});

group('Generator - Complete Build', () => {
  bench('Generate complete CSS (all utilities)', () => {
    execSync(`echo "${utilities.all}" | ../zig-out/bin/headwind build --stdout`, {
      encoding: 'utf-8',
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
