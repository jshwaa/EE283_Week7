#!/bin/bash
#$ -N RNAseq
#$ -q bio,pub64
#$ -pe openmp 8
#$ -R y
#$ -t 1-2

#change -t to 1-376 according to sample number in folder README

module load samtools/1.3
module load tophat/2.1.0
module load bowtie2

ref="/pub/jcrapser/Bioinformatics_Course/ref/dmel-all-chromosome-r6.13.fasta"
gtf="/pub/jcrapser/Bioinformatics_Course/ref/dmel-all-r6.26.gtf"

prefix=`head -n $SGE_TASK_ID RNAseq.prefixes.txt | tail -n 1`


multimapping=4    # number of reads reported for multimapping
bowtie2 -k $multimapping -X2000 --mm --threads 8 -x $ref -1 ${prefix}1_001.fq.gz -2 ${prefix}2_001.fq.gz 2>$log | samtools view -bS - > aligned/$SGE_TASK_ID.bowtie.bam
samtools sort aligned/$SGE_TASK_ID.bowtie.bam -o aligned/$SGE_TASK_ID.bowtie.sort.bam
samtools index

tophat -p 8 -G $gtf -o aligned $ref READ1.fq.gz READ2.fq.gz
samtools sort aligned/accepted_hits.bam -o aligned/accepted_hits.sort.bam
samtools index
