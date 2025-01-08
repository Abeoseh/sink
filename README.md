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
|	|___mk_manifest.sh
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

**mk_manifest.sh**
```
How to run:
./scripts/mk_manifest.sh fastq_folder

ex:
./scripts/mk_manifest.sh ./PRJEB3232/fastq
```

**qiime2_single.slurm**
```
single means only forward or reverse
ensure folders: qiime2_output and ./

How to run:
sbatch scripts/qiime2_single.slurm folder_containing_fastq_folder

ex:
sbatch scripts/qiime2_single.slurm PRJEB3232
```

**qiime2_paired.slurm**
```
paired means forward and reverse

How to run:
sbatch scripts/qiime2_paired.slurm folder_containing fastq folder

ex:
sbatch scripts/qiime2_paired.slurm PRJNA834026
```


**./scripts/combine_pt3.R**
```
$1 output folder name
$2 first phenotype
$3 second phenotype
$4 (""/T) keep NA as NA
./scripts/combine_pt3.R $1 $2 $3 $4

ex:
sbatch combine_pt3.sbatch "associated" "skin associated" "floor associated" # results in NA values being coded as 0
sbatch combine_pt3.sbatch "associated_na" "skin associated" "floor associated" "T" # results in NA staying as NA
```

**./run_all.sh**
```
$1 input folder (ensure it's located within ./csv_files)
$2 output folder (ensure folder ./output is created)
$3 amount of studies
./run_all.sh $1 $2 $3
```
ex:
./run_all.sh sink_nonsink sink_nonsink 4

Processing Notes:
- PRJEB3232 and PRJEB3250: only have one read per spot.
- PRJNA834026 had no taxonomy assigned and was dropped.


 ### provide accessions:
    ### automatically makes folders then downloads data (run table... then renames to project_run_table and accession list)
