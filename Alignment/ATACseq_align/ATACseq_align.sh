#!/bin/bash
#$ -N ATACseq_align
#$ -q epyc,pub64,bio,class
#$ -pe openmp 8
#$ -R y
#$ -t 1-24

module load bwa/0.7.8
module load samtools/1.3
module load picard-tools/1.87
module load java/1.8

cd ATACseq/labeled_ATACseq

ref="../../ref/dmel-all-chromosome-r6.26.fasta"

dict="../../ref/dmel-all-chromosome-r6.26.fasta.dict"


prefix=`head -n $SGE_TASK_ID ATACseq.prefix.txt | tail -n 1`


bwa mem -t 8 -M ${ref} ${prefix}1.fq.gz ${prefix}2.fq.gz | samtools view -bS - > ./aligned/${prefix}.bam
samtools sort aligned/$prefix.bam -o aligned/$prefix.sort.bam
samtools index aligned/$prefix.sort.bam
