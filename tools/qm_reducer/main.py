
dc=[2,3,4,7,11,12,15,18,19,20,23,26,27,28,31,34,35,39,43,47,50,51,52,55,58,59,60,63,66,67,68,71,75,79,82,83,84,87,90,91,92,95,98,99,100,103,107,111,114,115,116,119,122,123,124,127,128,130,131,135,137,139,143,146,147,151,155,156,158,159,163,167,171,175,178,179,183,187,191,194,195,199,203,207,210,211,212,215,218,219,220,223,226,227,231,235,239,242,243,244,247,250,251,252,255]

def gen_num(pattern):
    if len(pattern) == 0:
        return [0]
    prev = gen_num(pattern[:-1])
    ans0 = [i*2 for i in prev]
    ans1 = [i*2+1 for i in prev]
    if pattern[-1] == '0':
        return ans0
    elif pattern[-1] == '1':
        return ans1
    else:
        return ans0+ans1

import sys
all = []
for i in range(1,len(sys.argv)):
    all += gen_num(sys.argv[i])

from qm import QuineMcCluskey

solver = QuineMcCluskey()
ans = solver.simplify(all, dc=dc)
print(','.join(["8'b"+each.replace('-','x') for each in ans]))
