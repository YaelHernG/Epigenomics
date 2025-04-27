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
#$ -N Heatmaps_job
#
# Send an email after the job has finished
#$ -m e
#$ -M yaelhgs@gmail.com
#
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh
#
# Add any modules you might require:
module load deeptools/2.5.3
#
# Write your commands in the next line
OUT="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results"

plotHeatmap \
    -m $OUT/matrix_H3K27ac_promoters.tab.gz \
    -out $OUT/heatmap_H3K27ac_promoters_zcore.png \
    --refPointLabel "center" \
    --heatmapHeight 10 \
    --regionsLabel "Promoters" \
    --plotTitle "A. H3K27ac signal at Promoters" \
    --colorMap "RdBu" \
    --zMin -3 --zMax 3

plotHeatmap \
    -m $OUT/matrix_H3K27ac_PIRs.tab.gz \
    -out $OUT/heatmap_H3K27ac_PIRs_zcore.png \
    --refPointLabel "center" \
    --heatmapHeight 10 \
    --regionsLabel "PIRs" \
    --plotTitle "B. H3K27ac signal at PIRs" \
    --colorMap "RdBu" \
   --zMin -3 --zMax 3
