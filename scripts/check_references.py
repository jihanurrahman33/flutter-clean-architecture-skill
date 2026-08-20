#!/usr/bin/env python3
"""
References Checker: Scans all markdown files to verify local links.
"""

import os
import sys
import re

root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
checked_count = 0
broken_count = 0

def check_markdown_file(file_path):
    global checked_count, broken_count
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    file_dir = os.path.dirname(file_path)
    matches = re.findall(r"\[.*?\]\((?!http|https|#|mailto:)(.*?)\)", content)

    for target in matches:
        clean_target = target.split("#")[0]
        if not clean_target:
            continue

        if clean_target.startswith("file:///"):
            resolved = clean_target[8:]
            if sys.platform == "win32" and re.match(r"^[a-zA-Z]:\/", resolved):
                resolved = resolved.replace("/", "\\")
        else:
            resolved = os.path.normpath(os.path.join(file_dir, clean_target))

        checked_count += 1
        if not os.path.exists(resolved):
            print(f"❌ Broken link in {os.path.relpath(file_path, root_dir)}: -> {target}")
            broken_count += 1

def scan_dir(dir_path):
    for root, dirs, files in os.walk(dir_path):
        if "node_modules" in root or ".git" in root:
            continue
        for file in files:
            if file.endswith(".md"):
                check_markdown_file(os.path.join(root, file))

if __name__ == "__main__":
    print("\n🔍 Checking all markdown references in repository...")
    scan_dir(root_dir)

    if broken_count == 0:
        print(f"✅ REFERENCE CHECK PASS: All {checked_count} local links verified successfully!\n")
        sys.exit(0)
    else:
        print(f"\n❌ REFERENCE CHECK FAILED: Found {broken_count} broken link(s) across {checked_count} checked.\n")
        sys.exit(1)
