#!/bin/bash
#$ -S bin/bash
#$ -j y
#$ -cwd
#$ -M sw424@drexel.edu
#$ -l h_rt=24:00:00
#$ -P rosenclassPrj
#$ -pe shm 24
#$ -l mem_free=10G
#$ -l h_vmem=16G
#$ -q all.q

. /etc/profile.d/modules.sh
module load shared
module load proteus
module load sge/univa
module load gcc/4.8.1
module load bowtie2/2.2.5

USERNAME=sw424
MP_LOC=/home/$USERNAME/tools/metaphlan2

SEQS=/home/$USERNAME/genStats/urban/seqs

SCRATCH=/scratch/$USERNAME/tutorial_urban
OUT=/home/$USERNAME/tutorial_urban/

SRAS=($(ls $SEQS/*.fastq*))
SRRS=($(for sra in ${SRAS[@]};do echo ${sra%_*.fastq.gz};done | uniq))

MP2=$MP_LOC/metaphlan2.py
MMT=$MP_LOC/utils/merge_metaphlan_tables.py
BT2=/mnt/HA/opt/bowtie2/2.2.5/bin/bowtie2
MP2DB=$MP_LOC/db_v20/mpa_v20_m200.pkl
BT2DB=$MP_LOC/db_v20/mpa_v20_m200

mkdir -p $SCRATCH
mkdir -p $OUT

for srr in ${SRRS[@]}
do
	$MP2 --nproc 24 ${srr}_1.fastq.gz,${srr}_2.fastq.gz --input_type fastq --mpa_pkl $MP2DB --bowtie2_exe $BT2 --bowtie2db $BT2DB --bowtie2out $SCRATCH/${srr#$SEQS\/}.bowtie2.bz2 -o $SCRATCH/${srr#$SEQS\/}_profile.txt
done

$MMT $SCRATCH/*_profile.txt > $OUT/merged_table.txt

exit
