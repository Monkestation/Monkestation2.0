# import OS module
import os
from os.path import isfile, join

def prnt(name):
    print("\"" + name + "\",")

# Get the list of all files and directories
dir_list = os.listdir(".")
# prints all files
for file in dir_list:
    if file.endswith(".ogg"):
        prnt(file)
    elif not isfile(file):
        dir_list2 = os.listdir("./"+file)
        # prints all files
        for file2 in dir_list2:
            if file2.endswith(".ogg"):
                prnt(file+ "/" + file2)
