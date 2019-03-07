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
