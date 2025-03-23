# import OS module
import os
from os.path import isfile, join

all = []

# Get the list of all files and directories
dir_list = os.listdir(".")
# prints all files
for file in dir_list:
    if not file.endswith(".ogg"):
        continue
    all.append(file[:-4])

for file in all:
    if file.endswith("_ask") or file.endswith("_exclaim"):
        continue

    if "_" in file:
        print(f"[goon.\"{file.replace("_", " ").title()}\"]")
    else:
        print(f"[goon.{file.replace("_", " ").title()}]")

    print(f"path='{file}.ogg'")
    if (f"{file}_ask" in all):
        print(f"ask_path='{file}_ask.ogg'")
        print(f"exclaim_path='{file}_exclaim.ogg'")
    print()
