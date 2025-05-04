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
#$ -N matrixscan_jobs
#
# Send an email after the job has finished
#$ -m e
#$ -M my_email@my_domain.com
#
#$ -t 1-48  # 1-24: pirs_real, 25-48: pirs_shuffled
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh
#
# Add any modules you might require: 
module load rsat/8sep2021


# ===== Configuración de rutas =====
DATA_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/data"
REAL_FASTA_DIR="${DATA_DIR}/pirs_real_fasta_chr"
SHUFFLED_FASTA_DIR="${DATA_DIR}/pirs_shuffled_fast_chr"
MOTIFS_FILE="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/motifs/JASPAR2022_CORE_non-redundant_pfms_transfac.txt"
BG_FILE="${DATA_DIR}/PIRs_bm.bg"  # ¡Asegúrate de que esta ruta sea correcta!
RESULTS_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results/matrixscan_chr"
OUTLOGS_DIR="/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/scripts/pirs/jobs/outlogs"

# Crear directorios de resultados y logs (si no existen)
mkdir -p "${RESULTS_DIR}/pirs_real" "${RESULTS_DIR}/pirs_shuffled" "${OUTLOGS_DIR}"

# ===== Determinar tipo (real/shuffled) y cromosoma =====
CHROMOSOMES=( $(seq 1 22) X Y )

if [ $SGE_TASK_ID -le 24 ]; then
    TYPE="real"
    CHR_IDX=$((SGE_TASK_ID - 1))
    CHROMOSOME=${CHROMOSOMES[$CHR_IDX]}
    INPUT_FASTA="${REAL_FASTA_DIR}/chr${CHROMOSOME}.fa"
    OUTPUT_TSV="${RESULTS_DIR}/pirs_real/chr${CHROMOSOME}.tsv"
else
    TYPE="shuffled"
    CHR_IDX=$((SGE_TASK_ID - 25))
    CHROMOSOME=${CHROMOSOMES[$CHR_IDX]}
    INPUT_FASTA="${SHUFFLED_FASTA_DIR}/chr${CHROMOSOME}.fa"
    OUTPUT_TSV="${RESULTS_DIR}/pirs_shuffled/chr${CHROMOSOME}.tsv"
fi

# ===== Ejecutar Matrix-Scan =====
echo "Iniciando Matrix-Scan para ${TYPE}, cromosoma ${CHROMOSOME}..."
echo "Input: ${INPUT_FASTA}"
echo "Output: ${OUTPUT_TSV}"

matrix-scan \
  -quick \
  -i "${INPUT_FASTA}" \
  -m "${MOTIFS_FILE}" \
  -matrix_format transfac \
  -seq_format fasta \
  -origin start \
  -lth score 0.8 \
  -bgfile "${BG_FILE}" \
  -2str \
  -o "${OUTPUT_TSV}"

# ===== Verificar si el archivo de salida se generó =====
if [ -f "${OUTPUT_TSV}" ]; then
    echo "Resultados guardados en: ${OUTPUT_TSV}"
else
    echo "Error: No se generó el archivo de salida. Revisa los logs." >&2
fi
