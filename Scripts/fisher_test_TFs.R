#!/usr/bin/env Rscript

#------------------------------------------
#Análisis de Enriquecimiento de Factores de Transcripción (TFs) usando Fisher's Exact Test
#Descripcion:
#' Este script realiza un análisis de enriquecimiento comparando la frecuencia de sitios de unión 
#' de factores de transcripción (TFs) en conjuntos de promotores reales vs. aleatorizados.
#' Utiliza el test exacto de Fisher para evaluar significancia estadística y corrige 
#' los p-valores mediante FDR (False Discovery Rate).
#Uso:
#' Rscript fisher_test_TFs.R <promoters_real.tsv> <promoters_shuffled.tsv> <output_results.csv>
# Autor: Yael Daniel Hernandez Gonzalez
#Fecha: 05/05/2025

#-------------------------------------------

library(data.table)
# Verificación de argumentos
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
  stop("Usage: Rscript fisher_test_TFs.R promoters_real.tsv promoters_shuffled.tsv output_results.csv")
}

real_file <- args[1]      # Ruta al archivo de promotores reales
shuff_file <- args[2]     # Ruta al archivo de promotores aleatorizados
output_csv <- args[3]     # Ruta de salida para los resultados

# ───────────────────────────────
# 1. Leer columnas necesarias
# ───────────────────────────────
cols_needed <- c("seq_id", "ft_name")
dt_real <- fread(real_file, select = cols_needed)
dt_shuf <- fread(shuff_file, select = cols_needed)

# ───────────────────────────────
# 2. Contar por TF en cada dataset
# ───────────────────────────────
#' - Elimina duplicados de secuencias para cada TF.
#' - Calcula el número de secuencias únicas que contienen cada TF.
dt_real_unique <- unique(dt_real)
dt_shuf_unique <- unique(dt_shuf)

real_counts <- dt_real_unique[, .(n_seq_real = uniqueN(seq_id)), by = ft_name]
shuf_counts <- dt_shuf_unique[, .(n_seq_shuf = uniqueN(seq_id)), by = ft_name]

n_total_real <- uniqueN(dt_real_unique$seq_id) # Total de secuencias reales únicas
n_total_shuf <- uniqueN(dt_shuf_unique$seq_id) # Total de secuencias aleatorizadas únicas

# ───────────────────────────────
# 3. Fusionar y construir tablas 2x2
# ───────────────────────────────
#' - Fusiona los conteos reales y aleatorizados por TF.
#' - Completa con ceros si un TF no aparece en un conjunto.
#' - Calcula las frecuencias "no enriquecidas" para cada grupo.
merged <- merge(real_counts, shuf_counts, by = "ft_name", all = TRUE)
merged[is.na(n_seq_real), n_seq_real := 0]
merged[is.na(n_seq_shuf), n_seq_shuf := 0]

merged[, `:=`(
  n_not_real = n_total_real - n_seq_real, # Secuencias reales SIN el TF
  n_not_shuf = n_total_shuf - n_seq_shuf #Secuencias aleatorizadas SIN el TF
)]

# ───────────────────────────────
# 4. Fisher Test por TF
# ───────────────────────────────
#' - Para cada TF, construye una tabla 2x2:
#'   |                | Real | Aleatorizado |
#'   |----------------|------|--------------|
#'   | Con TF         | a    | b            |
#'   | Sin TF         | c    | d            |
#' - Calcula el odds ratio y p-valor usando \code{fisher.test}.
results <- merged[, {
  mat <- matrix(c(n_seq_real, n_not_real, n_seq_shuf, n_not_shuf), nrow = 2)
  test <- fisher.test(mat)
  list(
    n_seq_real = n_seq_real,
    n_seq_shuf = n_seq_shuf,
    odds_ratio = unname(test$estimate),
    p_value = test$p.value
  )
}, by = ft_name]

# ───────────────────────────────
# 5. FDR
# ───────────────────────────────
#' - Ajusta los p-valores usando el método FDR (Benjamini-Hochberg).
results[, fdr := p.adjust(p_value, method = "fdr")]

# ───────────────────────────────
# 6. Exportar resultado
# ───────────────────────────────
#' - Guarda los resultados en un CSV con columnas:
#'   - \code{ft_name}: Nombre del TF.
#'   - \code{n_seq_real}, \code{n_seq_shuf}: Conteos.
#'   - \code{odds_ratio}, \code{p_value}, \code{fdr}: Métricas estadísticas.
fwrite(results, output_csv)

cat("✅ Análisis completado. Resultado en", output_csv, "\n")
