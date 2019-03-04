#!/bin/bash
#$ -N DNAseq_align
#$ -q epyc,pub64
#$ -pe openmp 8
#$ -R y
#$ -t 1-12

module load bwa/0.7.8
module load samtools/1.3
module load picard-tools/1.87
module load java/1.8

cd DNAseq/labeled_DNAseq

ref="../../ref/dmel-all-chromosome-r6.26.fasta"

dict="../../ref/dmel-all-chromosome-r6.26.fasta.dict"


prefix=`head -n $SGE_TASK_ID DNAseq.prefixes.txt | tail -n 1`


bwa mem -t 8 -M ${ref} ${prefix}_1.fq.gz.sanger.fq.gz ${prefix}_2.fq.gz.sanger.fq.gz | samtools view -bS - > ./aligned/${prefix}.bam
samtools sort aligned/$prefix.bam -o aligned/$prefix.sort.bam
#java -Xmx20g -jar /data/apps/picard-tools/1.87/AddOrReplaceReadGroups.jar I=aligned/$prefix.sort.bam O=aligned/$prefix.RG.bam SORT_ORDER=coordinate RGPL=sanger RGPU=D109LACXX RGLB=Lib1 RGID=$prefix RGSM=$prefix VALIDATION_STRINGENCY=LENIENT
#samtools index aligned/$prefix.RG.bam
