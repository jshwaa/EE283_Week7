#!/bin/bash
#$ -N index
#$ -q bio,pub64
#$ -pe openmp 8
#$ -R y

module load bowtie2/2.2.7
module load bwa/0.7.8
module load samtools/1.3
module load bcftools/1.3
module load enthought_python/7.3.2
module load gatk/2.4-7
module load picard-tools/1.87
module load java/1.7

ref="ref/dmel-all-chromosome-r6.13.fasta" #accidentally followed version format from slide notes, so r6.13 = r6.26
bwa index $ref 
samtools faidx $ref  
java -d64 -Xmx128g -jar /data/apps/picard-tools/1.87/CreateSequenceDictionary.jar R=$ref O=ref/dmel-all-chromosome-r6.13.fasta.dict
bowtie2-build $ref $ref
