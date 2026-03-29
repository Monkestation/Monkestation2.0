import fnmatch
import glob
import os
import re
import sys
import argparse
from collections import defaultdict

parser = argparse.ArgumentParser()
parser.add_argument("--fix", action="store_true", help="Auto-fix by appending #undef for missing local defines")
args = parser.parse_args()

parent_directories = [
    "code/**/*.dm",
    "monkestation/code/**/*.dm",
]

output_file_name = "define_sanity_output.txt"
how_to_fix_message = "Please #undef the above defines or remake them as global defines in the code/__DEFINES directory."

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def blue(text):
    return "\033[34m" + str(text) + "\033[0m"

def post_error(define_name, file, github_error_style):
    if github_error_style:
        print(f"::error file={file},title=Define Sanity::{define_name} is defined locally in {file} but not undefined locally!")
    else:
        print(red(f"- Failure: {define_name} is defined locally in {file} but not undefined locally!"))

# simple way to check if we're running on github actions, or on a local machine
on_github = os.getenv("GITHUB_ACTIONS") == "true"

# This files/directories are expected to have "global" defines, so they must be exempt from this check.
# Add directories as string here to automatically be exempt in case you have a non-complaint file name.
excluded_files = [
    #  Wildcard directories, all files are expected to be exempt.
    "code/__DEFINES/*.dm",
    "code/__HELPERS/*.dm",
    "code/_globalvars/*.dm",
    # TGS files come from another repository so lets not worry about them.
    "code/modules/tgs/**/*.dm",
    "monkestation/code/__DEFINES/*.dm",
    "monkestation/code/__HELPERS/*.dm",
    "monkestation/code/_globalvars/*.dm",
]

define_regex = re.compile(r"^(\s+)?#define\s?([A-Z0-9_]+)\(?(.+)\)?")

files_to_scan = []

if not on_github:
    print(blue(f"Running define sanity check outside of Github Actions.\nFor assistance, a '{output_file_name}' file will be generated at the root of your directory if any errors are detected."))

for dir in parent_directories:
    for code_file in glob.glob(dir, recursive=True):
        exempt_file = False
        for exempt_directory in excluded_files:
            if fnmatch.fnmatch(code_file, exempt_directory):
                exempt_file = True
                break

        if exempt_file:
            continue

        # If the "base path" of the file starts with an underscore, it's assumed to be an encapsulated file holding references to the other files in its folder and is exempt from the checks.
        if os.path.basename(code_file)[0] == "_":
            continue

        files_to_scan.append(code_file)

located_error_tuples = []
by_file = defaultdict(set)

for applicable_file in files_to_scan:
    with open(applicable_file, encoding="utf8") as f:
        file_contents = f.read()
    for define in define_regex.finditer(file_contents):
        define_name = define.group(2)
        if not re.search(rf"#undef\s" + define_name, file_contents):
            located_error_tuples.append((define_name, applicable_file))
            by_file[applicable_file].add(define_name)

if located_error_tuples:
    if args.fix:
        for file, defines in by_file.items():
            with open(file, "rb") as f:
                raw = f.read()

            text = raw.decode("utf8", errors="ignore")
            stripped = text.rstrip()

            # If the file already ends with a #undef, don't force a blank line
            needs_newline = not re.search(r"#undef\s+[A-Z0-9_]+\s*$", stripped)

            with open(file, "a", encoding="utf8") as f:
                if needs_newline:
                    f.write("\n")
                for d in sorted(defines):
                    f.write(f"#undef {d}\n")

        print(green(f"Fixed {sum(len(v) for v in by_file.values())} defines."))
        sys.exit(0)

    string_list = []
    for error in located_error_tuples:
        if not on_github:
            post_error(error[0], error[1], False)
            string_list.append(f"{error[0]} is defined locally in {error[1]} but not undefined locally!")
        else:
            post_error(error[0], error[1], True)

    if len(string_list):
        with open(output_file_name, "w") as output_file:
            output_file.write("\n".join(string_list))
            output_file.write("\n\n" + how_to_fix_message)

    print(red(how_to_fix_message))
    sys.exit(1)

else:
    print(green("No unhandled local defines found."))
