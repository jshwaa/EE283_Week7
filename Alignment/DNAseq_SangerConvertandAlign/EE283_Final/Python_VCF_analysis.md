# EE283 Final Project

As I am not too familiar with python, I chose to write a python program that reads an input vcf file (generated from the 
DNAseq pipeline built and used in this repository) and:

	i.  Calculate the frequency of the "ALT" allele for each position & sample
	ii. Output frequency and coverage for each sample
  
The vcf format is as follows:

![vcf_format.png][vcf]

The key-value pair legend in red indicates the relevant information:

	-GT:
	-AD:
	-DP:
	-GQ:
	-PL:

  
 To do this, I need to accomplish the following:
 -iterate over each variant position in the vcf file
  -for each variant, iterate over every sample to collect "ALT" allele frequency


[vcf]: https://github.com/jshwaa/EE283_Week7/blob/EE283_Final/Alignment/DNAseq_SangerConvertandAlign/EE283_Final/vcf_format.png
