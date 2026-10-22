# This tool checks your git status for any deleted, modified, renamed or untracked files,
# to make sure that they are properly included in the dme.
# Run tools/dme-sorter before running this, this wont automatically remove non-existent files for you.
# - flleeppyy
import subprocess
import sys

#python makes me want to CRY
def get_git_modified_untracked_deleted_and_renamed_files():
	result = subprocess.run(['git', 'status', '--porcelain'], stdout=subprocess.PIPE, text=True)
	modified_untracked = []
	deleted = []

	for line in result.stdout.splitlines():
		status = line[:2]
		path_part = line[3:].strip()

		allowed_prefixes = ['code/', 'monkestation/', 'yogstation/', 'goon/']

		if status.startswith('R'):
			_, new_path = path_part.split(' -> ', 1)
			file_path = new_path
		else:
			file_path = path_part

		if not any(file_path.startswith(prefix) for prefix in allowed_prefixes) or not file_path.endswith('.dm'):
			continue

		file_path = file_path.replace("/", "\\")

		# M for modified, ?? for untracked, R for renamed (new path)
		if status in ('M ', '??') or status.startswith('R'):
			modified_untracked.append(file_path)

		# D for deleted
		if status in (' D', 'D '):
			deleted.append(file_path)

	return modified_untracked, deleted

def ensure_files_in_dme(files, deleted_files, dme_path):
	try:
		with open(dme_path, 'r') as dme_file:
			dme_contents = dme_file.read()
	except FileNotFoundError:
		print(f"Error: The .dme file was not found at '{dme_path}'")
		return
	except Exception as e:
		print(f"An error occurred while reading '{dme_path}': {e}")
		return

	missing_files = [file for file in files if file not in dme_contents]
	deleted_still_in_dme = [file for file in deleted_files if file in dme_contents]

	if missing_files:
		print("The following files are missing from the .dme file:")
		for file in missing_files:
			print(f" - {file}")

	if deleted_still_in_dme:
		print("The following deleted files are still included in the .dme file:")
		for file in deleted_still_in_dme:
			print(f" - {file}")

	if not missing_files and not deleted_still_in_dme:
		print("All relevant files are present in the .dme file.")

if __name__ == "__main__":
	if len(sys.argv) != 2:
		print("Usage: python script_name.py <path_to_dme_file>")
		print("Check")
		sys.exit(1)

	dme_file_path = sys.argv[1]
	modified_and_renamed_files, deleted_files = get_git_modified_untracked_deleted_and_renamed_files()
	ensure_files_in_dme(modified_and_renamed_files, deleted_files, dme_file_path)
