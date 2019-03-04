First, make sure you have a reference genome...
```
$ cd Bioinformatics_Course/refs
$ wget ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/current/fasta/dmel-all-chromosome-r6.26.fasta.gz
$ gunzip *fasta.gz
```

..and you index it:
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
module load java/1.8

ref="ref/dmel-all-chromosome-r6.26.fasta"
bwa index $ref 
samtools faidx $ref  
java -d64 -Xmx128g -jar /data/apps/picard-tools/1.87/CreateSequenceDictionary.jar R=$ref O=ref/dmel-all-chromosome-r6.26.fasta.dict
bowtie2-build $ref $ref
```

Also, in Bioinformatics_Course/DNAseq:
```
$ ls *1.fq.gz | sed 's/_1.fq.gz//' > DNAseq.prefixes.txt
$ ls *fq.gz > convertfiles.txt
```

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
adding readgroups (note: make sure you ```mkdir``` an "aligned" subdirectory within the labeled_DNAseq folder first to output to):
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
module load java/1.8

cd DNAseq/labeled_DNAseq

ref="../../ref/dmel-all-chromosome-r6.26.fasta"

dict="../../ref/dmel-all-chromosome-r6.26.fasta.dict"


prefix=`head -n $SGE_TASK_ID DNAseq.prefixes.txt | tail -n 1`


bwa mem -t 8 -M ${ref} ${prefix}_1.fq.gz.sanger.fq.gz ${prefix}_2.fq.gz.sanger.fq.gz | samtools view -bS - > ./aligned/${prefix}.bam
samtools sort aligned/$prefix.bam -o aligned/$prefix.sort.bam
# java -Xmx20g -jar /data/apps/picard-tools/1.87/AddOrReplaceReadGroups.jar I=aligned/$prefix.sort.bam O=aligned/$prefix.RG.bam SORT_ORDER=coordinate RGPL=sanger RGPU=D109LACXX RGLB=Lib1 RGID=$prefix RGSM=$prefix VALIDATION_STRINGENCY=LENIENT
# samtools index aligned/$prefix.RG.bam
```

Next, mark duplicates on sorted bam files with picard-tools' MarkDuplicates ```qsub markdups.sh```:
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

prefixlist="../DNAseq.prefixes.txt"

prefix=`head -n $SGE_TASK_ID $prefixlist | tail -n 1`

java -Xmx20g -jar /data/apps/picard-tools/1.87/MarkDuplicates.jar I=$prefix.sort.bam O=$prefix.marked_duplicates.bam M=$prefix.marked_duplicates.txt VALIDATION_STRINGENCY=LENIENT
```

Add read groups and index the resulting bam file:
```
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
```
Then ```qrsh -q``` into a node and merge bam files within the folder containing them:
```
$ module load samtools
$ samtools merge merged.marked_duplicates.RG.bam *duplicates.RG.bam
```

Run indel realignment:
```
$ module load java/1.8
$ module load gatk/3.7
$ java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T RealignerTargetCreator -R ../../../ref/dmel-all-chromosome-r6.26.fasta.dict -I merged.marked_duplicates.RG.bam -o merged.realigner.intervals --fix_misencoded_quality_scores
$ java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T IndelRealigner -R ../../../ref/dmel-all-chromosome-r6.26.fasta.dict -I merged.marked_duplicates.RG.bam -targetIntervals merged.realigner.intervals -o merged.realigned.bam --fix_misencoded_quality_scores
```

java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T RealignerTargetCreator -R ../../../ref/dmel-all-chromosome-r6.13.fasta.dict -I merged.marked_duplicates.RG.bam -o merged.realigner.intervals --fix_misencoded_quality_scores
java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T IndelRealigner -R ../../../ref/dmel-all-chromosome-r6.13.fasta.dict -I merged.marked_duplicates.RG.bam -targetIntervals merged.realigner.intervals -o merged.realigned.bam --fix_misencoded_quality_scores
