
# Indexing and aligning ATACseq, DNAseq, and RNAseq

First download the D.mel reference genome:

```
$ wget ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/current/fasta/dmel-all-chromosome-r6.26.fasta.gz

$ ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/current/gtf/dmel-all-r6.26.gtf.gz

$ wget ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/current/fasta/md5sum.txt

$ md5sum -c md5sum.txt
```


Change directories and create prefixes files:

```
#ATACSeq in folder with labeled files
$ ls *R1.fq.gz | sed 's/1.fq.gz//' > ATACseq.prefix.txt

#DNAseq in folder with labeled files
$ ls *1.fq.gz | sed 's/_1.fq.gz//' > DNAseq.prefixes.txt

#RNAseq in subfolder with individual sample files i.e. sample 1:
$ ls *1_001.fastq.gz | sed 's/1_001.fastq.gz//' > RNAseq.prefixes.txt
```


Decompress GTF and reference genome files and then index:

```
#!/bin/bash
#$ -N index
#$ -q bio,pub64
#$ -pe openmp 8
#$ -R y

module load bowtie2/2.2.7
module load bwa/0.7.8
module load samtools/1.3
module load bcftools/1.3
module load enthought_python/7.3.2
module load gatk/2.4-7
module load picard-tools/1.87
module load java/1.7

ref="ref/dmel-all-chromosome-r6.13.fasta" #accidentally followed version format from slide notes, so r6.13 = r6.26
bwa index $ref 
samtools faidx $ref  
java -d64 -Xmx128g -jar /data/apps/picard-tools/1.87/CreateSequenceDictionary.jar R=$ref O=ref/dmel-all-chromosome-r6.13.fasta.dict
bowtie2-build $ref $ref
```


Use ```mkdir``` to make an "aligned" subfolder within sample folder, then run ATACseq alignment:

```
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
```


Use ```mkdir``` to make an "aligned" subfolder within sample folder, then do DNAseq alignment: 

```
#!/bin/bash
#$ -N DNAseq_align
#$ -q bio,pub64
#$ -pe openmp 8
#$ -R y
#$ -t 1-12

module load bwa/0.7.8
module load samtools/1.3
module load picard-tools/1.87
module load java/1.7

cd DNAseq/labeled*

ref="../../ref/dmel-all-chromosome-r6.13.fasta"

dict="../../ref/dmel-all-chromosome-r6.13.fasta.dict"


prefix=`head -n $SGE_TASK_ID DNAseq.prefixes.txt | tail -n 1`


bwa mem -t 8 -M ${ref} ${prefix}_1.fq.gz ${prefix}_2.fq.gz | samtools view -bS - > ./aligned/${prefix}.bam
samtools sort aligned/$prefix.bam -o aligned/$prefix.sort.bam
java -Xmx20g -jar /data/apps/picard-tools/1.87/AddOrReplaceReadGroups.jar I=folder/$prefix.sort.bam O=aligned/$prefix.RG.bam SORT_ORDER=coordinate RGPL=sanger RGPU=D109LACXX RGLB=Lib1 RGID=$prefix RGSM=$prefix VALIDATION_STRINGENCY=LENIENT
samtools index aligned/$prefix.RG.bam
```


Use ```mkdir``` to make an "aligned" subfolder in individual sample subfolders, ```cd``` to sample subfolder, then run RNAseq alignment:

```
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
```
