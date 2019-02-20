"""
Name: Josh Crapser
Assignment: Reorganize file directories/files
"""

import os
import glob
import shutil

"""
# raw data, cp to your dir, untar
/bio/share/Bioinformatics_Course.tar
make barcode files "ATACbarcodes.txt" and "DNAbarcodes.txt"
"""

shutil.copy("ATACbarcodes.txt", "./Bioinformatics_Course/ATACbarcodes.txt") #move barcode files into directory that you copied and decompressed
shutil.copy("DNAbarcodes.txt", "./Bioinformatics_Course/DNAbarcodes.txt")
os.chdir('./Bioinformatics_Course') #move into directory

os.mkdir('ATACseq/labeled_ATACseq')
os.mkdir('DNAseq/labeled_DNAseq')
        
        
folders=["ATACseq", "DNAseq"] #define folders to relabel
barcodes={"ATACseq":"ATACbarcodes.txt", "DNAseq":"DNAbarcodes.txt"} #pair folder with barcode file one level above
        
newDict={} #make an empty barcode:sample name dictionary

for i in folders: #for each folder
    f=open(barcodes[i], 'r') #open corresponding barcode file
    os.chdir('./{}'.format(i)) #move into it
    for line in f: #for every barcode line in text file
        line = line.strip('\n') #remove return character(s)    
        splitLine = line.split() #split each line by white space
        if i == "DNAseq": #flip key location for DNA or ATAC
            newDict[(splitLine[1])] = splitLine[0] #make key/value pairs out of barcode file
        elif i == "ATACseq":
            newDict[(splitLine[0])] = '_'.join(splitLine[1:])
    print(newDict)
    f.close()
    files = glob.glob('*.fq.gz') #glob names of all fastq files in folder
    for line in files: #for each file name
        splitLine = line.split('_') #split name by "_"
        splitLine = splitLine[1:]  #remove "sample" prefix
        if i == "DNAseq": #change barcode location for DNA or ATAC
            barcode =(line.split('_'))[0]
        elif i == "ATACseq":   
            barcode = splitLine[3] #grab the common sample identifier (the barcode)
        prefix = newDict[barcode] #find sample name from barcode file
        newname = prefix+'_'+'_'.join(splitLine) #create new file name
        shutil.copy(line, './labeled_'+i+'/'+newname) #copy files over
    os.chdir('..') #step back out to copy next folder 