#!/bin/bash
#$ -N ATACseq_align
#$ -q bio,pub64
#$ -pe openmp 8
#$ -R y
#$ -t 1-24

module load bwa/0.7.8
module load samtools/1.3
module load picard-tools/1.87
module load java/1.7

cd ATACseq/labeled*

ref="../../ref/dmel-all-chromosome-r6.13.fasta"

dict="../../ref/dmel-all-chromosome-r6.13.fasta.dict"


prefix=`head -n $SGE_TASK_ID ATACseq.prefix.txt | tail -n 1`


bwa mem -t 8 -M ${ref} ${prefix}1.fq.gz ${prefix}2.fq.gz | samtools view -bS - > ./aligned/${prefix}.bam
samtools sort aligned/$prefix.bam -o aligned/$prefix.sort.bam
java -Xmx20g -jar /data/apps/picard-tools/1.87/AddOrReplaceReadGroups.jar I=folder/$prefix.sort.bam O=aligned/$prefix.RG.bam SORT_ORDER=coordinate RGPL=sanger RGPU=D109LACXX RGLB=Lib1 RGID=$prefix RGSM=$prefix VALIDATION_STRINGENCY=LENIENT
samtools index aligned/$prefix.RG.bam
