import sys

old = sys.argv[1]
# print len(sys.argv)
new = []
for letter in old:
	if letter == 'A':
		new.append('T')
	if letter == 'G':
		new.append('C')
	if letter == 'C':
		new.append('G')
	if letter == 'T':
		new.append('A')
sys.stdout.write("".join(new))