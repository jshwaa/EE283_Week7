#!/bin/bash
#$ -N DNAseq_UnifiedGenotyper
#$ -q epyc,pub64,bio,class
#$ -pe openmp 24
#$ -R y

module load gatk/3.7
module load java/1.8

cd DNAseq/labeled_DNAseq/aligned

ref="../../../ref/dmel-all-chromosome-r6.26.fasta"

java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T UnifiedGenotyper -nt 8 -R $ref -I merged.realigned.bam -gt_mode DISCOVERY -o rawSNPS-Q30.vcf
java -jar  /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T UnifiedGenotyper -nt 8 -R $ref -I merged.realigned.bam -gt_mode DISCOVERY -glm INDEL -o inDels-Q30.vcf
