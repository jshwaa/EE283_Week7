According to the read me in the Bioinformatics_Course/DNAseq/ folder, we should convert the fastq files to sanger format first before aligning this time..

So, from the Bioinformatics_Course directory, ```qsub sangerconvert.sh```:

```
```

Then align the converted fastq files to the reference D. melanogaster genome with ```qsub DNAseq_align.sh```
