
Make sure you have the files and ran the python script to distribute and relabel them:
```
$ cp /bio/share/Bioinformatics_Course.tar
$ tar -xvf Bioinformatics_Course.tar
$ python EE283_Week7.py
```

Then make sure you have a reference genome...
```
$ cd Bioinformatics_Course/ref
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

ref="dmel-all-chromosome-r6.26.fasta"
bwa index $ref 
samtools faidx $ref  
java -d64 -Xmx128g -jar /data/apps/picard-tools/1.87/CreateSequenceDictionary.jar R=$ref O=ref/dmel-all-chromosome-r6.26.fasta.dict
bowtie2-build $ref $ref
```

Also, in Bioinformatics_Course/ATACseq:
```
$ ls *R1.fq.gz | sed 's/1.fq.gz//' > ATACseq.prefix.txt
```

Then align the fastq files to the reference D. melanogaster genome with ```ATACseq_align.sh``` and index (note: make sure you ```mkdir``` an "aligned" subdirectory within the labeled_ATACseq folder first to output to):
```
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
```

Then normalize across samples to generate a genome coverage bed and convert it to a BigWig:
```
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
```
