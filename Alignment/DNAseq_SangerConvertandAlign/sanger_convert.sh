#!/bin/bash
#$ -N DNA_sanger_convert
#$ -q epyc,pub64
#$ -pe openmp 24
#$ -R y
#$ -t 1-24

module load bwa/0.7.8
module load samtools/1.3
module load picard-tools/1.87
module load java/1.7

cd DNAseq/labeled_DNAseq

prefix=`head -n $SGE_TASK_ID convertfiles.txt | tail -n 1`

/pub/jcrapser/seqtk/seqtk seq -Q64 -V $prefix | gzip -c > $prefix.sanger.fq.gz
