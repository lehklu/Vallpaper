import os
import sys
import subprocess
import argparse

dir_path = os.path.dirname(os.path.realpath(__file__))

parser = argparse.ArgumentParser(
    description="Crop a verticlal image into smaller ones with a given ratio."
)
parser.add_argument("n", help="number of desktops", type=int)
parser.add_argument("filename", help="filename of the image")
parser.add_argument("--ratio", help="your screen ratio, default is 16/9", default="16/9")
args = vars(parser.parse_args())

n = args["n"]
filename = args["filename"]
ratio = eval(args["ratio"])

identify_output = subprocess.check_output(["identify", filename])
identify_output = identify_output.decode()
dimensions = identify_output.split()[2]
x, y = dimensions.split("x")
x = int(x)
y = int(y)

overlap = (x / ratio * n - y) / (n - 1)
overlap = int(overlap)

out_filenames = os.path.join(dir_path, "cropped-%d.jpg")
cmd = ["convert", filename, "-crop", f"1x{n}+0+{overlap}@", out_filenames]
subprocess.check_output(cmd)
