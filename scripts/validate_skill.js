#!/usr/bin/env node

/**
 * Skill Validator
 * Verifies that SKILL.md has valid metadata, required sections, and all reference links exist.
 */

const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const skillFile = path.join(rootDir, 'SKILL.md');

console.log(`\n🔍 Validating AI Skill structure: ${skillFile}`);

if (!fs.existsSync(skillFile)) {
  console.error('❌ Error: SKILL.md not found at project root!');
  process.exit(1);
}

const content = fs.readFileSync(skillFile, 'utf8');

// Check YAML frontmatter
const frontmatterRegex = /^---\r?\n([\s\S]*?)\r?\n---/;
const match = content.match(frontmatterRegex);

if (!match) {
  console.error('❌ Error: SKILL.md is missing valid YAML frontmatter (--- ... ---)!');
  process.exit(1);
}

const frontmatter = match[1];
if (!frontmatter.includes('name:')) {
  console.error('❌ Error: Frontmatter is missing "name" field!');
  process.exit(1);
}
if (!frontmatter.includes('description:')) {
  console.error('❌ Error: Frontmatter is missing "description" field!');
  process.exit(1);
}

// Check Required Sections
const requiredSections = [
  'Architectural Invariants',
  'Rule Severity Definitions',
  'Golden Decision Hierarchy',
  'Mandatory Pre-Coding Workflow',
  'Procedural Workflows',
  'Progressive Disclosure Reference Index',
  'Final Verification Checklist',
];

let missingSections = 0;
for (const section of requiredSections) {
  if (!content.includes(section)) {
    console.error(`❌ Error: SKILL.md missing required section: "${section}"`);
    missingSections++;
  }
}

if (missingSections > 0) {
  process.exit(1);
}

// Check reference files
const refDir = path.join(rootDir, 'references');
if (!fs.existsSync(refDir)) {
  console.error('❌ Error: references/ directory not found!');
  process.exit(1);
}

const linkRegex = /\[.*?\]\((?:file:\/\/\/.*?\/)?references\/(.*?\.md)\)/g;
let linkMatch;
let brokenLinks = 0;
let checkedLinks = 0;

while ((linkMatch = linkRegex.exec(content)) !== null) {
  checkedLinks++;
  const refFileName = linkMatch[1];
  const refFilePath = path.join(refDir, refFileName);
  if (!fs.existsSync(refFilePath)) {
    console.error(`❌ Error: Broken reference link in SKILL.md: references/${refFileName}`);
    brokenLinks++;
  }
}

if (checkedLinks === 0) {
  console.error('❌ Error: No reference links found in SKILL.md!');
  process.exit(1);
}

if (brokenLinks > 0) {
  process.exit(1);
}

console.log('✅ SKILL VALIDATION PASS: SKILL.md is complete, valid, and all references exist!\n');
process.exit(0);
