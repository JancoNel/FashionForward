import os
import datetime
import subprocess
import shutil

BRAND_PREFIX = "Code parsed using PASFMT on"
Branding = f"{BRAND_PREFIX} {datetime.datetime.now()}"

def build_index(root_dir="."):
    files_map = {}
    for root, dirs, files in os.walk(root_dir):
        for filename in files:
            if filename.lower().endswith(".pas"):
                filepath = os.path.join(root, filename)
                try:
                    with open(filepath, "r", encoding="utf-8") as f:
                        content = f.read()
                except Exception:
                    with open(filepath, "r", encoding="latin-1") as f:
                        content = f.read()
                files_map[filepath] = content
    return files_map


def first_nonempty_line(text):
    for line in text.splitlines():
        if line.strip() != "":
            return line.strip()
    return ""


def has_branding(content):
    first = first_nonempty_line(content)
    return BRAND_PREFIX in first


def prepend_branding(filepath, content):
    comment = "{ " + Branding + " }\n\n"
    new_content = comment + content
    try:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(new_content)
    except Exception:
        with open(filepath, "w", encoding="latin-1") as f:
            f.write(new_content)


def run_pasfmt(filepath):
    pasfmt = shutil.which("pasfmt")
    if not pasfmt:
        return False
    try:
        subprocess.run([pasfmt, filepath], check=False)
        return True
    except Exception:
        return False


def main():
    files = build_index()
    if not files:
        print("No .pas files found.")
        return

    for path, content in files.items():
        if has_branding(content):
            print(f"Skipping (already branded): {path}")
            continue

        print(f"Branding: {path}")
        prepend_branding(path, content)

        formatted = run_pasfmt(path)
        if formatted:
            print(f"Formatted with pasfmt: {path}")
        else:
            print(f"pasfmt not found or failed for: {path} (skipped formatting)")


if __name__ == "__main__":
    main()
