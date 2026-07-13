#!/usr/bin/env python3
import os
from pathlib import Path


def count_lines_in_pas_files():
    total_lines = 0
    file_count = 0

    for path in Path(".").rglob("*.pas"):
        try:
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                lines = f.readlines()
                total_lines += len(lines)
                file_count += 1
                print(f"{path}: {len(lines)} lines")
        except Exception as e:
            print(f"Error reading {path}: {e}")

    print("\n" + "=" * 50)
    print(f"Total .pas files: {file_count}")
    print(f"Total lines: {total_lines}")


if __name__ == "__main__":
    count_lines_in_pas_files()
