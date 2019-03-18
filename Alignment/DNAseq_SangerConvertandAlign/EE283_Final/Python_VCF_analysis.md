# EE283 Final Project

As I am not too familiar with python, I chose to write a python program that reads an input vcf file (generated from the 
DNAseq pipeline built and used in this repository) and:

	i.  Calculate the frequency of the "ALT" allele for each position & sample
	ii. Output frequency and coverage for each sample
  
  
The vcf format is as follows:

![vcf_format.png][vcf]

The key-value pair legend in red indicates the relevant "genotype field" information, values of which are color coded with respective sample IDs above:

	-GT: Genotype; 0=REF allele, 1=first ALT allele, 2=2nd ALT allele, etc (i.e. 0/0 homozygous REF, 1/1 homozygous ALT)
	-AD: Allele depth (unfiltered # of reads supporting each allele except uninformative reads) reported as AD=REF,ALT (counts)
	-DP: Depth of coverage/filtered depth (#filtered reads supporting each allele including uninformative reads)
	-GQ: Phred-scaled confidence of genotype assignment, normalized to the most likely genotype
	-PL: Phred-scaled normalized likelihoods of possible genotypes used in "GQ" confidence readout, with the most likely genotype 		being assigned a PL of 0.

  
 To do this variant analysis, I need to accomplish the following:
 
 i) iterate over each variant position in the vcf file and sum the ALT (and total) alleles indicated by each sample GT
 	
	-divide ALT allele sum by total allele sum across samples per variant for ALT allele frequency 
	-replace GT:AD:DP:GQ:PL sample information with each sample's ALT allele frequency (reported as # ALT alleles out of the diploid 2)
	
	
 ii) for each variant, iterate over every sample to collect ALT (and total) AD and DP read counts 
 	
	-divide each sample's ALT read counts by total read counts for ALT frequency (using AD), and report each sample's coverage (DP)



First, remove VCF header and comments and cut relevant record fields at the command line to make a txt file for python:
```
$ grep -v "^##" pass.SNPs.vcf | cut -f1,2,4,5,6,10,11,12,13,14,15,16,17,18,19,20,21 | cat > sample_alleles.txt
```

Then ```module load anaconda/3.7-5.3.0/``` and in ```spyder``` use python to store every VCF sample line/field as an entry in a list:
```
f = open('./sample_alleles.txt', 'r')
lines = f.readlines()
f.close()
```

Such that indexing the list with anything other than 0 (which returns VCF column headers according to our file trimming above) returns the allele information for every sample, separated by '\t' for easy parsing.
```
In: lines[0]
Out: '#CHROM\tPOS\tREF\tALT\tQUAL\tA4_1\tA4_2\tA4_3\tA5_1\tA5_2\tA5_3\tA6_1\tA6_2\tA6_3\tA7_1\tA7_2\tA7_3\n'

In: lines[1]
Out: '2L\t5372\tT\tA\t5976.47\t1/1:0,43:43:99:1383,111,0\t1/1:0,39:39:99:1412,114,0\t1/1:0,29:29:78:988,78,0\t0/0:20,0:20:57:0,57,706\t0/0:23,0:23:69:0,69,842\t0/0:22,0:22:66:0,66,838\t1/1:0,24:24:66:819,66,0\t1/1:0,30:30:72:889,72,0\t1/1:0,21:22:45:574,45,0\t0/0:46,0:46:99:0,126,1553\t0/0:28,0:28:81:0,81,1009\t0/0:27,0:27:81:0,81,1059\n'
```

Now use this format to create an output document (based on the number of samples) that has new column headers to take into account the calculated information to be reported:

```
numsamples = int(input("How many samples?: "))

total_ALT_count=list(range(1,len(lines)+1))

total_ALT_freq=list(range(1,len(lines)+1))

f=open('ALT_allele_quant.txt', 'w')

f.write("#CHROM\tPOS\tREF\tALT\tQUAL\tA4_1 (ALT count:AD:DP)\tA4_2\tA4_3 (ALT count:AD:DP)\tA5_1 (ALT count:AD:DP)\tA5_2 (ALT count:AD:DP)\tA5_3 (ALT count:AD:DP)\tA6_1 (ALT count:AD:DP)\tA6_2 (ALT count:AD:DP)\tA6_3 (ALT count:AD:DP)\tA7_1 (ALT count:AD:DP)\tA7_2 (ALT count:AD:DP)\tA7_3 (ALT count:AD:DP)\tTotal_ALT_count\tTotal_ALT_frequency\n")
```

Use a for loop to first iterate over each variant (VCF file lines) and write a corresponding line to the new file, including the positional information from the original VCF file:

```
for i in lines[1:]:
    POS=1
    ALT=0
    CHROM=i.split('\t')[0]
    POS_allele=i.split('\t')[1]
    REF_allele=i.split('\t')[2]
    ALT_allele=i.split('\t')[3]
    QUAL=i.split('\t')[4]
    f.write("{}\t{}\t{}\t{}\t{}\t".format(CHROM, POS_allele, REF_allele, ALT_allele, QUAL))
```    

Now, use a second for loop to iterate over every sample for each variant and report the # of ALT alleles out of 2, the frequency of ALT reads out of all unfiltered reads (from AD), and the depth of coverage (from DP). At the same time, use a variable to store cumulative ALT counts over each sample iteration and report the total ALT allele count and frequency across all samples at the end of the record.

```
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
```

After closing the document, this python script will have generated a .txt file characterization alternate allele genotype and read frequencies within and across samples using data stored within VCF files (here saved as "ALT_allele_quant.txt", 10 lines of which are included in the repository). 

[vcf]: https://github.com/jshwaa/EE283_Week7/blob/EE283_Final/Alignment/DNAseq_SangerConvertandAlign/EE283_Final/vcf_format.png
