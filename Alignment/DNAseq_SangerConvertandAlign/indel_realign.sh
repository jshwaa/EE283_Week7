#!/bin/bash
#$ -N DNAseq_indelRealign
#$ -q epyc,pub64,class
#$ -pe openmp 8
#$ -R y

module load bwa/0.7.8
module load samtools/1.3
module load gatk/3.7
module load picard-tools/1.87
module load java/1.8

cd DNAseq/labeled_DNAseq/aligned

ref="../../../ref/dmel-all-chromosome-r6.26.fasta"

java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $ref -I merged.RG.bam -o merged.realigner.intervals 
java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T IndelRealigner -R $ref -I merged.RG.bam -targetIntervals merged.realigner.intervals -o merged.realigned.bam
