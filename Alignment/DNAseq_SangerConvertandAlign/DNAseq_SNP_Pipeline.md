According to the read me in the Bioinformatics_Course/DNAseq/ folder, we should convert the fastq files to sanger format first before aligning this time..

So, from the Bioinformatics_Course directory, ```qsub sangerconvert.sh```:

```
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
```

Then align the converted fastq files to the reference D. melanogaster genome with ```qsub DNAseq_sanger_align.sh```, without yet 
adding readgroups:
```
#!/bin/bash
#$ -N DNAseq_align
#$ -q epyc,pub64
#$ -pe openmp 8
#$ -R y
#$ -t 1-12

module load bwa/0.7.8
module load samtools/1.3
module load picard-tools/1.87
module load java/1.7

cd DNAseq/labeled_DNAseq

ref="../../ref/dmel-all-chromosome-r6.13.fasta"

dict="../../ref/dmel-all-chromosome-r6.13.fasta.dict"


prefix=`head -n $SGE_TASK_ID DNAseq.prefixes.txt | tail -n 1`


bwa mem -t 8 -M ${ref} ${prefix}_1.fq.gz.sanger.fq.gz ${prefix}_2.fq.gz.sanger.fq.gz | samtools view -bS - > ./aligned/${prefix}.bam
samtools sort aligned/$prefix.bam -o aligned/$prefix.sort.bam
# java -Xmx20g -jar /data/apps/picard-tools/1.87/AddOrReplaceReadGroups.jar I=aligned/$prefix.sort.bam O=aligned/$prefix.RG.bam SORT_ORDER=coordinate RGPL=sanger RGPU=D109LACXX RGLB=Lib1 RGID=$prefix RGSM=$prefix VALIDATION_STRINGENCY=LENIENT
# samtools index aligned/$prefix.RG.bam
```

Next, mark duplicates with picard-tools MarkDuplicates tool with ```qsub markdups.sh```:
```
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

ref="../../../ref/dmel-all-chromosome-r6.13.fasta"

dict="../../../ref/dmel-all-chromosome-r6.13.fasta.dict"

prefixlist="../DNAseq.prefixes.txt"

prefix=`head -n $SGE_TASK_ID $prefixlist | tail -n 1`

java -Xmx20g -jar /data/apps/picard-tools/1.87/MarkDuplicates.jar I=prefix.sanger.bam O=prefix.marked_duplicates.bam M=marked_duplicates.txt VALIDATION_STRINGENCY=LENIENT
```
