
First, get the files:
```
$ cp /bio/share/Bioinformatics_Course.tar
$ tar -xvf Bioinformatics_Course.tar
```

Make barcode files "ATACbarcodes.txt" and "DNAbarcodes.txt" with column pairs of the sample ID's and labels found in ```DNAseq/README.DNA_samples.txt``` and run the python script EE283_Week7.py

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

So, from the Bioinformatics_Course directory, ```qsub sanger_convert.sh```:
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

Then align the converted fastq files to the reference D. melanogaster genome with ```qsub DNAseq_sanger_align.sh```, add readgroups and index (note: make sure you ```mkdir``` an "aligned" subdirectory within the labeled_DNAseq folder first to output to):
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
java -Xmx20g -jar /data/apps/picard-tools/1.87/AddOrReplaceReadGroups.jar I=aligned/$prefix.sort.bam O=aligned/$prefix.RG.bam SORT_ORDER=coordinate RGPL=sanger RGPU=D109LACXX RGLB=Lib1 RGID=$prefix RGSM=$prefix VALIDATION_STRINGENCY=LENIENT
samtools index aligned/$prefix.RG.bam
```

Then ```qrsh -q``` into a node, merge bam files within the folder containing them and index the merged file:
```
$ module load samtools
$ samtools merge merged.RG.bam *RG.bam
$ samtools index merged.RG.bam
```

Then run indel realignment with ```qsub indel_realign.sh```:
```
#!/bin/bash
#$ -N DNAseq_indelRealign
#$ -q epyc,pub64,class
#$ -pe openmp 8
#$ -R y

module load bwa/0.7.8
module load samtools/1.3
module load gatk/3.7
module load picard-tools/1.87
module load java/1.8

cd DNAseq/labeled_DNAseq/aligned

ref="../../../ref/dmel-all-chromosome-r6.26.fasta"

java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $ref -I merged.RG.bam -o merged.realigner.intervals 
java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T IndelRealigner -R $ref -I merged.RG.bam -targetIntervals merged.realigner.intervals -o merged.realigned.bam
```

Call variants (SNPs and indels) with Haplotype caller ```qsub variant_HaplotypeCaller.sh```:
```
#!/bin/bash
#$ -N DNAseq_callVariants
#$ -q epyc,pub64,class
#$ -pe openmp 8
#$ -R y

module load gatk/3.7
module load java/1.8

cd DNAseq/labeled_DNAseq/aligned

ref="../../../ref/dmel-all-chromosome-r6.26.fasta"

java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T HaplotypeCaller -R $ref -I merged.realigned.bam -o merged.raw.snp.indel.HaplotypeCaller.vcf
```

..or with Unified Genotyper ```qsub UnifiedGenotyper.sh```
```
#!/bin/bash
#$ -N DNAseq_UnifiedGenotyper
#$ -q epyc,pub64,bio,class
#$ -pe openmp 24
#$ -R y

module load gatk/3.7
module load java/1.8

cd DNAseq/labeled_DNAseq/aligned

ref="../../../ref/dmel-all-chromosome-r6.26.fasta"

java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T UnifiedGenotyper -nt 8 -R $ref -I merged.realigned.bam -gt_mode DISCOVERY -o rawSNPS-Q30.vcf
java -jar  /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T UnifiedGenotyper -nt 8 -R $ref -I merged.realigned.bam -gt_mode DISCOVERY -glm INDEL -o inDels-Q30.vcf
```

Finally, filter variants ```qsub variant_filtering.sh```
```
#!/bin/bash
#$ -N DNAseq_variantFilter
#$ -q epyc,pub64,bio,class
#$ -pe openmp 24
#$ -R y

module load gatk/3.7
module load java/1.8
module load samtools

cd DNAseq/labeled_DNAseq/aligned

ref="../../../ref/dmel-all-chromosome-r6.26.fasta"

java -jar /data/apps/gatk/3.7/GenomeAnalysisTK.jar -T VariantFiltration -R $ref -V rawSNPS-Q30.vcf --mask inDels-Q30.vcf --maskExtension 5 --maskName InDel --clusterWindowSize 10 --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" --filterName "BadValidation" --filterExpression "QUAL < 30.0" --filterName "LowQual" --filterExpression "QD < 5.0" --filterName "LowVQCBD" --filterExpression "FS > 60.0" --filterName "FisherStrand" -o Q30-SNPs.vcf
cat Q30-SNPs.vcf | grep 'PASS\|^#' > pass.SNPs.vcf
cat inDels-Q30.vcf | grep 'PASS\|^#' > pass.inDels.vcf
bgzip -c pass.SNPs.vcf >pass.SNPs.vcf.gz
tabix -p vcf pass.SNPs.vcf.gz
bgzip -c pass.inDels.vcf >pass.inDels.vcf.gz
tabix -p vcf pass.inDels.vcf.gz
```
