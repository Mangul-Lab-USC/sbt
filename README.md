# SBT (Seeing Beyond the Target) tool


## Installing SBT

- Step 1 - Install [Conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html)
- Step 2 - Download the SBT tool
  - git clone https://github.com/jaquejbrito/sbt
  - cd sbt
  - ./install.sh
- Step 3 - Download the SBT [database](https://figshare.com/articles/dataset/Database_files_for_the_software_tool_SBT_Seeing_Beyond_the_Target_/14342414)
  - wget https://ndownloader.figshare.com/files/27416207 -O dbs.zip
  - unzip dbs.zip
- Step 4 - Configure the SBT tool editing the file settings.sh to:
  - define the path to the tools called within SBT
  - set the genome reference build version (hg19/hg38)
  - set the steps to be run by SBT

## Running the SBT tool

- ./sbt.sh input.bam output_dir
