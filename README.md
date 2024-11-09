Directory Structure:

```
.
|___ README.md
|___project_info
|   |___project_updates.pptx
|
|___scripts
|   |___download_sra.sh
|   |___sra.log
|   |___qiime2_single.slurm
|   |___qiime2_paired.slurm
|
|___csv_files
|   |___combine
|        |___`counts with taxonomy (4 total)`
|
|___PRJEB3232
|   |___PRJEB3232_SraRunTable.txt
|   |___SRR_Acc_List.txt
|   |___fastq
|   |   |___`**all fastq files`
|   |___qiime2_output
|       |___`**qimme2 and dada2 output except counts with taxonomy`
|
|___PRJEB3250
|   |___PRJEB3250_SraRunTable.txt
|   |___SRR_Acc_List.txt
|   |___fastq
|       |___`**all fastq files`
|   |___qiime2_output
|       |___`**qimme2 and dada2 output except counts with taxonomy`
|
|___PRJNA878661
|   |___PRJNA878661_SraRunTable.txt
|   |___SRR_Acc_List.txt
|   |___fastq
|       |___`**all fastq files`
|   |___qiime2_output
|       |___`**qimme2 and dada2 output except counts with taxonomy`
|
|___PRJNA834026
|   |___PRJNA834026_SraRunTable.txt
|   |___SRR_Acc_List.txt
|   |___fastq
|       |___`**all fastq files`
|   |___qiime2_output
|       |___`**qimme2 and dada2 output except counts with taxonomy`
|
```

All initial fastq downloading was done locally. Afterwards, files were processed on the cluster.
**download_sra.sh**
```
`download_sra.sh` takes a SRR_Acc_List.txt and downloads all the fastq files for the given accessions. It automatically
loop over the project IDs provided in as an array called "projects" within `download_sra.sh`.

How to run:
- Change the projects in the array named "projects" to your desired project(s). 
        - The script assumes you named your folders with the project name. All of this can be changed.
- Open command prompt and navigate to the scripts folder.
- Run the following command: `download_sra.sh > sra.log 2>&1` 
- Output: a file in the scripts folder called sra.log which contains std error and std Output.
```

**qiime2_single.slurm**
```
single means only forward or reverse

How to run:
./qiime2_single.slurm folder_containing fastq folder

ex:
./qiime2_single.slurm PRJEB3232
```

**qiime2_paired.slurm**
```
paired means forward and reverse

How to run:
./qiime2_paired.slurm folder_containing fastq folder

ex:
./qiime2_paired.slurm PRJNA834026
```

Processing Notes:
- PRJEB3232 and PRJEB3250: only have one read per spot.



 ### provide accessions:
    ### automatically makes folders then downloads data (run table... then renames to project_run_table and accession list)
