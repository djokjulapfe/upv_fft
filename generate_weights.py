import math

n = int(int(input("n : ")) / 2)
precision = int(input("precision : "))

if n & (n - 1) != 0 or n < 2:
    print("ERROR: n must be a power of two larger than 2, but " + str(2 * n) + " was given")
    exit()

if precision < 1 or precision > 15:
    print("precision must be an integer between 1 and 15, but " + str(precision) + " was given")

weights: list = []

for i in range(n):
    angle = math.pi * i / n
    re = math.cos(angle)
    im = math.sin(angle)
    re_approx = round(re * 2 ** precision)
    im_approx = round(im * 2 ** precision)
    weights.append(
        3 * 4 * " " + "(to_signed(" + str(re_approx) + ", word_size), to_signed(" + str(im_approx) + ", word_size))" + (
            "" if i == n - 1 else ",") + "\n")

output_pre: list = [
    "--------------------------------------------------------------------------------\n",
    "-- file generated by generate_weights.py\n",
    "-------------------------------------------------------------------------------\n",
    "\n",
    "library ieee;\n",
    "use ieee.std_logic_1164.all;\n",
    "use ieee.numeric_std.all;\n",
    "\n",
    "use work.types.all;\n",
    "\n",
    "package weights is\n",
    "\n",
    "    constant num_weights : integer := " + str(n) + ";\n",
    "    constant weight_precision : integer := " + str(precision) + ";\n",
    "\n",
    "    constant W : complex_vector(0 to 7) := (\n"
]

output_post: list = [
    "        );\n",
    "\n",
    "end package weights;\n"
]

with open("weights.vhd", "w") as file:
    for line in output_pre + weights + output_post:
        file.write(line)