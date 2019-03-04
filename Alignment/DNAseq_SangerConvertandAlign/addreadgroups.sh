#!/bin/bash
#$ -N DNAseq_RG_and_index
#$ -q epyc,pub64
#$ -pe openmp 8
#$ -R y
#$ -t 1-12

module load samtools/1.3
module load picard-tools/1.87
module load java/1.7

cd DNAseq/labeled_DNAseq/aligned

prefixlist="../DNAseq.prefixes.txt"

prefix=`head -n $SGE_TASK_ID $prefixlist | tail -n 1`

java -Xmx20g -jar /data/apps/picard-tools/1.87/AddOrReplaceReadGroups.jar I=$prefix.marked_duplicates.bam O=$prefix.marked_duplicates.RG.bam SORT_ORDER=coordinate RGPL=sanger RGPU=D109LACXX RGLB=Lib1 RGID=$prefix RGSM=$prefix VALIDATION_STRINGENCY=LENIENT
samtools index $prefix.marked_duplicates.RG.bam
