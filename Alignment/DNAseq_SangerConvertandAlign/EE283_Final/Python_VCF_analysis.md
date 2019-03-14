# EE283 Final Project

As I am not too familiar with python, I chose to write a python program that reads an input vcf file (generated from the 
DNAseq pipeline built and used in this repository) and:

	i.  Calculate the frequency of the "ALT" allele for each position & sample
	ii. Output frequency and coverage for each sample
  
The vcf format is as follows:

![vcf_format.png][vcf]

The key-value pair legend in red indicates the relevant "genotype field" information for each sample:

	-GT: Genotype; 0=REF allele, 1=first ALT allele, 2=2nd ALT allele, etc (i.e. 0/0 homozygous REF, 1/1 homozygous ALT)
	-AD: Allele depth (unfiltered # of reads supporoting each allele except uninformative reads)
	-DP: Depth of coverage/filtered depth (#filtered reads supporting each allele including uninformative reads)
	-GQ: Phred-scaled confidence of genotype assignment, normalized to the most likely genotype
	-PL: Phred-scaled normalized likelihoods of possible genotypes used in "GQ" confidence readout, with the most likely genotype 		being assigned a PL of 0.

  
 To do this, I need to accomplish the following:
 
 1) iterate over each variant position in the vcf file and sum the ALT (and total) alleles indicated by each sample GT
 	
	-divide sum by total sample allele number per variant for ALT allele frequency and by per-sample allele number (2) for sample 		frequency
	
 2) for each variant, iterate over every sample to collect ALT (and total) AD and DP read counts 
 	
	-divide each sample's respective ALT read counts by total read counts for raw ALT frequency (AD) and coverage (DP)
	-output values

First, remove VCF header and comments and cut relevant record fields at the command line to make a txt file for python:
```
$ grep -v "^##" pass.SNPs.vcf | cut -f1,2,4,5,6,10,11,12,13,14,15,16,17,18,19,20,21 | cat > sample_alleles.txt
```


[vcf]: https://github.com/jshwaa/EE283_Week7/blob/EE283_Final/Alignment/DNAseq_SangerConvertandAlign/EE283_Final/vcf_format.png
