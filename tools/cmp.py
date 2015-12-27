spim_pcs = []
spim_block_len = []
block_len = 0
spimc = 0
spimstart = 0

cpu_pcs = []
cpu_block_len = []
cpuc = 0

with open('spimlog.txt') as f:
    for line in f:
        if spimstart :
            if(len(line)<2):
                continue
            pc = line.split('[')[1]
            pc = pc.split(']')[0]
            spim_pcs.append(int(pc,16))
            spimc +=1
        if 'main' in line:
            spimstart = 1

for i in range(0,spimc-1) : 
    if (spim_pcs[i+1] != spim_pcs[i]+4):
        spim_block_len.append(block_len+1)
        block_len = 0
    else:
        block_len+=1

with open('pc.txt') as f:
    for line in f:
        num = line.split(',')[1]
        if(len(num) < 1):
            continue
        else:
            pc = int(num)
            cpu_pcs.append(pc)
            cpuc += 1

block_len = 0
for i in range(0,cpuc-2):
    if(cpu_pcs[i+1] == 0 and cpu_pcs[i]+1 != cpu_pcs[i+2] and cpu_pcs[i]+2 != cpu_pcs[i+2]):
        cpu_block_len.append(block_len+1)
        block_len = -1
    elif(cpu_pcs[i+1] == 0 and cpu_pcs[i]+1 == cpu_pcs[i+2]):
        block_len = block_len
    else:
        block_len += 1

i = 0
for num in spim_block_len:
    print num,
    print cpu_block_len[i]
    i+=1
