#!/bin/bash
#$ -N ATACseq_coverage
#$ -q epyc,pub64,class,bio
#$ -pe openmp 8
#$ -R y
#$ -t 1-24

module load bwa/0.7.8
module load samtools/1.3
module load picard-tools/1.87
module load java/1.7
module load bedtools
module load jje/kent/2014.02.19 
module load enthought_python/7.3.2  

cd ATACseq/labeled_ATACseq/aligned

ref="../../../ref/dmel-all-chromosome-r6.26.fasta"
prefixlist="../ATACseq.prefix.txt"

prefix=`head -n $SGE_TASK_ID $prefixlist | tail -n 1`

Nreads=`samtools view -c -F 4 $prefix.bam`
Scale=`echo "1.0/($Nreads/1000000)" | bc -l`

samtools view -b $prefix.sort.bam | genomeCoverageBed -ibam - -g $ref -bg -scale $Scale > $prefix.coverage
 
bedGraphToBigWig $prefix.coverage $ref.fai $prefix.bw
