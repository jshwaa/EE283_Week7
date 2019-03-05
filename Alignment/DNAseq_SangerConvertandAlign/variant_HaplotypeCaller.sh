#!/bin/bash
#$ -N DNAseq_callVariants
#$ -q epyc,pub64,class
#$ -pe openmp 8
#$ -R y

module load gatk/3.7
module load java/1.8

cd DNAseq/labeled_DNAseq/aligned

ref="../../../ref/dmel-all-chromosome-r6.26.fasta"

java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T HaplotypeCaller -R $ref -I merged.realigned.bam -o merged.raw.snp.indel.HaplotypeCaller.vcf
