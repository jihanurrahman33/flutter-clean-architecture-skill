#!/usr/bin/env python3
"""
Skill Validator: Verifies SKILL.md metadata, required sections, and reference links.
"""

import os
import sys
import re

root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
skill_file = os.path.join(root_dir, "SKILL.md")

print(f"\n🔍 Validating AI Skill structure: {skill_file}")

if not os.path.exists(skill_file):
    print("❌ Error: SKILL.md not found at project root!")
    sys.exit(1)

with open(skill_file, "r", encoding="utf-8") as f:
    content = f.read()

# Check YAML frontmatter
match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
if not match:
    print("❌ Error: SKILL.md is missing valid YAML frontmatter (--- ... ---)!")
    sys.exit(1)

frontmatter = match.group(1)
if "name:" not in frontmatter:
    print("❌ Error: Frontmatter is missing 'name' field!")
    sys.exit(1)
if "description:" not in frontmatter:
    print("❌ Error: Frontmatter is missing 'description' field!")
    sys.exit(1)

# Check Required Sections
required_sections = [
    "Architectural Invariants",
    "Rule Severity Definitions",
    "Golden Decision Hierarchy",
    "Mandatory Pre-Coding Workflow",
    "Procedural Workflows",
    "Progressive Disclosure Reference Index",
    "Final Verification Checklist",
]

missing_sections = 0
for section in required_sections:
    if section not in content:
        print(f"❌ Error: SKILL.md missing required section: '{section}'")
        missing_sections += 1

if missing_sections > 0:
    sys.exit(1)

# Check references
ref_dir = os.path.join(root_dir, "references")
if not os.path.exists(ref_dir):
    print("❌ Error: references/ directory not found!")
    sys.exit(1)

link_matches = re.findall(r"\[.*?\]\((?:file:\/\/\/.*?\/)?references\/(.*?\.md)\)", content)
if not link_matches:
    print("❌ Error: No reference links found in SKILL.md!")
    sys.exit(1)

broken_links = 0
for ref_file_name in link_matches:
    ref_file_path = os.path.join(ref_dir, ref_file_name)
    if not os.path.exists(ref_file_path):
        print(f"❌ Error: Broken reference link in SKILL.md: references/{ref_file_name}")
        broken_links += 1

if broken_links > 0:
    sys.exit(1)

print("✅ SKILL VALIDATION PASS: SKILL.md is complete, valid, and all references exist!\n")
sys.exit(0)
