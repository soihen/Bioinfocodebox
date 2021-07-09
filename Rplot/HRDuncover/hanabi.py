import os
import sys
import argparse

if __name__ == "__main__":

    bedfile = sys.argv[1]
    n=0
    bf=open(bedfile)
    for line in bf:
        if n==0:
            end=line.split()[2]
            chrs='chr1'
            n=1
        else:
            if chrs!=line.split()[0]:
                end=line.split()[2]
                chrs=line.split()[0]
            else:
                begin=line.split()[1]
                uncover=int(begin)-int(end)
                chrs=line.split()[0]
                print(chrs+'\t'+str(uncover))
                end=line.split()[2]

    bf.close()