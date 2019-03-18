#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 14 12:53:33 2019

@author: jcrapser
"""

f=open('./sample_alleles.txt', 'r')

lines=f.readlines()

f.close()

numsamples = int(input("How many samples?: "))

total_ALT_count=list(range(1,len(lines)+1))

total_ALT_freq=list(range(1,len(lines)+1))

f=open('ALT_allele_quant.txt', 'w')

f.write("#CHROM\tPOS\tREF\tALT\tQUAL\tA4_1 (ALT count:AD:DP)\tA4_2\tA4_3 (ALT count:AD:DP)\tA5_1 (ALT count:AD:DP)\tA5_2 (ALT count:AD:DP)\tA5_3 (ALT count:AD:DP)\tA6_1 (ALT count:AD:DP)\tA6_2 (ALT count:AD:DP)\tA6_3 (ALT count:AD:DP)\tA7_1 (ALT count:AD:DP)\tA7_2 (ALT count:AD:DP)\tA7_3 (ALT count:AD:DP)\tTotal_ALT_count\tTotal_ALT_frequency\n")

for i in lines[1:]:
    POS=1
    ALT=0
    CHROM=i.split('\t')[0]
    POS_allele=i.split('\t')[1]
    REF_allele=i.split('\t')[2]
    ALT_allele=i.split('\t')[3]
    QUAL=i.split('\t')[4]
    f.write("{}\t{}\t{}\t{}\t{}\t".format(CHROM, POS_allele, REF_allele, ALT_allele, QUAL))
    for j in range(5, numsamples+5):
        if (i.split('\t')[j]).split(':')[0] == '1/1':
            sample_ALT_AD=int(((i.split('\t')[j]).split(':')[1]).split(',')[1])
            sample_REF_AD=int(((i.split('\t')[j]).split(':')[1]).split(',')[0])
            sample_ALT_AD_freq=sample_ALT_AD/(sample_ALT_AD+sample_REF_AD)
            coverage=((i.split('\t')[j]).split(':')[2])
            f.write("{}:{}:{}\t".format("2",sample_ALT_AD_freq, coverage))
            ALT=ALT+2
        elif (i.split('\t')[j]).split(':')[0] == '1/0':
            sample_ALT_AD=int(((i.split('\t')[j]).split(':')[1]).split(',')[1])
            sample_REF_AD=int(((i.split('\t')[j]).split(':')[1]).split(',')[0])
            sample_ALT_AD_freq=sample_ALT_AD/(sample_ALT_AD+sample_REF_AD)
            coverage=((i.split('\t')[j]).split(':')[2])
            f.write("{}:{}:{}\t".format("1",sample_ALT_AD_freq, coverage))
            ALT=ALT+1
        elif (i.split('\t')[j]).split(':')[0] == '0/0':  
            sample_ALT_AD=int(((i.split('\t')[j]).split(':')[1]).split(',')[1])
            sample_REF_AD=int(((i.split('\t')[j]).split(':')[1]).split(',')[0])
            sample_ALT_AD_freq=sample_ALT_AD/(sample_ALT_AD+sample_REF_AD)
            coverage=((i.split('\t')[j]).split(':')[2])
            f.write("{}:{}:{}\t".format("0",sample_ALT_AD_freq, coverage))
    total_ALT_count[POS]=ALT
    total_ALT_freq[POS]=ALT/(2*len(range(5, numsamples+5)))
    f.write("{}\t{}\n".format(total_ALT_count[POS], total_ALT_freq[POS]))
    POS=POS+1
    
f.close   
