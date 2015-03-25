
infile = open("tmem.tmp", "r")
outfile = open("tmem_processed.tmp", "w")

a = []
for line in infile:
    a.append(line.split("\n")[0])

for i in range(0,len(a),2):
    outfile.write("t_buf = 64'h" + a[i+1] + a[i] + ";\n")


