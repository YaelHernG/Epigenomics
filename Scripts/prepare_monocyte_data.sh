#!/bin/bash
# Use current working directory
#$ -cwd
#
# Join stdout and stderr
#$ -j y
#
# Run job through bash shell
#$ -S /bin/bash
#
#You can edit the scriptsince this line
#
# Your job name
#$ -N prepare_monocyte_data
#
# Send an email after the job has finished
#$ -m e
#$ -M yaelhgs@gmail.com
#
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh
#
#
#
cd /mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/data

wget -O ENCFF931PZJ.bigWig "https://www.encodeproject.org/files/ENCFF931PZJ/@@download/ENCFF931PZJ.bigWig"

zcat PCHiC_peak_matrix_cutoff5.txt.gz | awk -F'\t' 'NR==1 || $12 > 0' > monocyte_interactions.tsv

awk -F'\t' '
NR>1 && ($1 ~ /^[0-9XY]+$/) && ($1 != "Y" || $3 <= 57227415) {
  print "chr"$1"\t"$2"\t"$3"\t"$4
}' monocyte_interactions.tsv \
| awk '$1 ~ /^chr([1-9]|1[0-9]|2[0-2]|X|Y|M)$/' \
| sort -k1,1 -k2,2n | uniq > Monocyte_Promoters_mainChr.bed

awk -F'\t' '
NR>1 && ($6 ~ /^[0-9XY]+$/) && ($6 != "Y" || $8 <= 57227415) {
  print "chr"$6"\t"$7"\t"$8"\t"$9
}' monocyte_interactions.tsv \
| awk '$1 ~ /^chr([1-9]|1[0-9]|2[0-2]|X|Y|M)$/' \
| sort -k1,1 -k2,2n | uniq > Monocyte_PIRs_mainChr.bed

echo "Archivos generados:"
wc -l Monocyte_*_mainChr.bed
