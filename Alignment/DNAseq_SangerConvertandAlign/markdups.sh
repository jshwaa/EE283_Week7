#!/bin/bash
#$ -N DNAseq_MarkDuplicates
#$ -q epyc,pub64
#$ -pe openmp 8
#$ -R y
#$ -t 1-12

module load bwa/0.7.8
module load samtools/1.3
module load picard-tools/1.87
module load java/1.7

cd DNAseq/labeled_DNAseq/aligned


prefixlist="../DNAseq.prefixes.txt"

prefix=`head -n $SGE_TASK_ID $prefixlist | tail -n 1`

java -Xmx20g -jar /data/apps/picard-tools/1.87/MarkDuplicates.jar I=$prefix.sort.sanger.bam O=$prefix.marked_duplicates.bam M=$prefix.marked_duplicates.txt VALIDATION_STRINGENCY=LENIENT
