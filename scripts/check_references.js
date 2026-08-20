#!/usr/bin/env node

/**
 * References Checker
 * Scans all markdown files in the repository to ensure all local markdown links resolve correctly.
 */

const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
let checkedCount = 0;
let brokenCount = 0;

function checkMarkdownFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const fileDir = path.dirname(filePath);

  // Match markdown links [text](path)
  const linkRegex = /\[.*?\]\((?!http|https|#|mailto:)(.*?)\)/g;
  let match;

  while ((match = linkRegex.exec(content)) !== null) {
    let target = match[1].split('#')[0]; // strip anchor
    if (!target) continue;

    // Handle file:/// absolute paths
    if (target.startsWith('file:///')) {
      target = target.replace(/^file:\/\/\//, '');
      // Handle windows paths e.g. c:/...
      if (process.platform === 'win32' && /^[a-zA-Z]:\//.test(target)) {
        target = target.replace(/\//g, '\\');
      }
    } else {
      target = path.resolve(fileDir, target);
    }

    checkedCount++;
    if (!fs.existsSync(target)) {
      console.error(`❌ Broken link in ${path.relative(rootDir, filePath)}: -> ${match[1]}`);
      brokenCount++;
    }
  }
}

function scanDir(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    if (entry.name === 'node_modules' || entry.name === '.git') continue;
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      scanDir(fullPath);
    } else if (entry.isFile() && entry.name.endsWith('.md')) {
      checkMarkdownFile(fullPath);
    }
  }
}

console.log('\n🔍 Checking all markdown references in repository...');
scanDir(rootDir);

if (brokenCount === 0) {
  console.log(`✅ REFERENCE CHECK PASS: All ${checkedCount} local links verified successfully!\n`);
  process.exit(0);
} else {
  console.log(`\n❌ REFERENCE CHECK FAILED: Found ${brokenCount} broken link(s) across ${checkedCount} checked.\n`);
  process.exit(1);
}
