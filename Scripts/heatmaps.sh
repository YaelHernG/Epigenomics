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
BW="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/data/ENCFF931PZJ.bigWig"
PROMOTERS="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/data/Monocyte_Promoters_final.bed"
PIRS="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/data/Monocyte_PIRs_final.bed"
OUT="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results"

### Promoters
computeMatrix reference-point \
    -S $BW \
    -R $PROMOTERS \
    --referencePoint center \
    -a 2000 -b 2000 \
    --binSize 50 \
    --missingDataAsZero \
    -out $OUT/matrix_H3K27ac_promoters.tab.gz

plotHeatmap \
    -m $OUT/matrix_H3K27ac_promoters.tab.gz \
    -out $OUT/heatmap_H3K27ac_promoters.png \
    --refPointLabel "center" \
    --heatmapHeight 10 \
    --regionsLabel "Promoters" \
    --plotTitle "A. H3K27ac signal at Promoters" \
    --colorMap "RdBu" \

### PIRs
computeMatrix reference-point \
    -S $BW \
    -R $PIRS \
    --referencePoint center \
    -a 2000 -b 2000 \
    --binSize 50 \
    --missingDataAsZero \
    -out $OUT/matrix_H3K27ac_PIRs.tab.gz

plotHeatmap \
    -m $OUT/matrix_H3K27ac_PIRs.tab.gz \
    -out $OUT/heatmap_H3K27ac_PIRs.png \
    --refPointLabel "center" \
    --heatmapHeight 10 \
    --regionsLabel "PIRs" \
    --plotTitle "B. H3K27ac signal at PIRs" \
    --colorMap "RdBu"

### Unir ambos heatmaps si ImageMagick está disponible
if command -v convert &> /dev/null; then
    convert -append $OUT/heatmap_H3K27ac_promoters.png \
                     $OUT/heatmap_H3K27ac_PIRs.png \
                     $OUT/heatmap_H3K27ac_combined.png
    echo "✅ Imagen combinada generada: heatmap_H3K27ac_combined.png"
else
    echo "⚠️ 'convert' no está disponible. Puedes combinar las imágenes luego en R o manualmente."
fi
