import argparse
parser = argparse.ArgumentParser(description = 'Example : python gen_spimasm.py q.S final.S')
parser.add_argument("src")
parser.add_argument("dst")
args = parser.parse_args()

def main():
    #parser.add_argument('--help', nargs='?', help='... -in q.S -out final.S')
    final = open(args.dst,'w')
    with open(args.src) as f:
        for line in f:
            line2 = line.lstrip('\t')
            line2 = line2.lstrip(' ')
            if len(line2) == 0:
                continue
            elif(line2[0] == '.' or line2[0] == '#'):
                continue
            else:
                print >>final, line,
    final.close()

if __name__ == "__main__":
    main()
