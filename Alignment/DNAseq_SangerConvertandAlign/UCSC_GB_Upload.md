To upload and visualize the DNAseq vcf file in the UCSC Genome Browser, first remove scaffolds that aren't 2L, 2R, 3L, 3R, 4, X, and Y, and prepend these chromosome labels with "chr":
```
$ cd Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned
$ grep "^#\|^2L\|^2R\|^3L\|^3R\|^4\|^X\|^Y" pass.SNPs.vcf | grep -v '_mapped_Scaffold' | sed 's/^2L/chr2L/' | sed 's/^2R/chr2R/' |sed 's/^3L/chr3L/' |\
sed 's/^3R/chr3R/' | sed 's/^4/chr4/' | sed 's/^X/chrX/' | sed 's/^Y/chrY/' | cat > SNPs_upload_JC.vcf
```

Then bgzip vcf files and index the resulting bgzips with tabix:
```
$ module load samtools
$ bgzip -c SNPs_upload_JC.vcf > SNPs_upload_JC.vcf.gz
$ tabix -p vcf SNPs_upload_JC.vcf.gz
$ bgzip -c pass.inDels.vcf > inDels_upload_JC.vcf.gz
$ tabix -p vcf inDels_upload_JC.vcf.gz
```

Change to the public student repository hosted by HPC and create symbolic links
```
$ cd /pub/public-www/jcrapser
$ mkdir EE283_Bioinformatics_Course
$ cd EE283*
$ ln -s /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/merged.realigned.bam merged.realigned.bam
$ ln -s /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/merged.realigned.bai merged.realigned.bai
$ ln -s /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/SNPs_upload_JC.vcf.gz SNPs_upload_JC.vcf.gz
$ ln -s /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/SNPs_upload_JC.vcf.gz.tbi SNPS_upload_JC.gz.tbi
$ ln -s /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/pass.inDels.vcf.gz pass.inDels.vcf.gz
$ ln -s /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/pass.inDels.vcf.gz.tbi pass.inDels.vcf.gz.tbi
```

And then make all directories leading up to your linked files executable by everyone, and the files themselves
readable by everyone with ```chmod```:
```
$ chmod a+x /pub/jcrapser/
$ chmod a+x /pub/jcrapser/Bioinformatics_Course
$ chmod a+x /pub/jcrapser/Bioinformatics_Course/DNAseq
$ chmod a+x /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq
$ chmod a+x /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned
$ chmod a+rx /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/merged.realigned.bam
$ chmod a+rx /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/merged.realigned.bai
$ chmod a+rx /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/SNPs_upload_JC.vcf.gz
$ chmod a+rx /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/SNPs_upload_JC.vcf.gz.tbi
$ chmod a+rx /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/pass.inDels.vcf.gz
$ chmod a+rx /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/pass.inDels.vcf.gz.tbi
```

Due to permissions issues with symbolic links, ```rm``` the symlinks in the public hosted repository and cp the respective files over from HPC local repositories.
```
$ cd /pub/public-www/jcrapser
$ mkdir EE283_Bioinformatics_Course
$ cd EE283*
$ cp /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/merged.realigned.bam ./merged.realigned.bam
$ cp /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/merged.realigned.bai ./merged.realigned.bai
$ cp /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/SNPs_upload_JC.vcf.gz ./SNPs_upload_JC.vcf.gz
$ cp /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/SNPs_upload_JC.vcf.gz.tbi ./SNPS_upload_JC.gz.tbi
$ cp /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/pass.inDels.vcf.gz ./pass.inDels.vcf.gz
$ cp /pub/jcrapser/Bioinformatics_Course/DNAseq/labeled_DNAseq/aligned/pass.inDels.vcf.gz.tbi ./pass.inDels.vcf.gz.tbi
```

Finally, import the symlinked files by URL into the UCSC Genome Browser, i.e.:
https://hpc.oit.uci.edu/~jcrapser/EE283_Bioinformatics_Course/merged.realigned.bai
