#!/usr/bin/env Rscript

#------------------------------------------
# Análisis de Enriquecimiento de TFs usando Fisher's Exact Test
# 
# Este script procesa los archivos generados por:
# - Count_promoters_real.sh (real_counts.tsv, total_real.txt)
# - Count_promoters_shuffled.sh (shuf_counts.tsv, total_shuf.txt)
#
# Autor: Yael Daniel Hernandez Gonzalez
# Fecha: 05/05/2025
#------------------------------------------

library(data.table)

# Verificación de argumentos
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
  stop("Usage: Rscript fisher_test_TFs.R <real_counts.tsv> <shuf_counts.tsv> <output_results.csv>")
}

# Rutas de entrada (ajustar según ubicación real)
output_dir <- "/mnt/atgc-d1/bioinfoII/yhernandezg/epigenomica/results/counts_tsv"
real_counts_file <- file.path(output_dir, "real_counts.tsv")
shuf_counts_file <- file.path(output_dir, "shuf_counts.tsv")
total_real_file <- file.path(output_dir, "total_real.txt")
total_shuf_file <- file.path(output_dir, "total_shuf.txt")
output_csv <- args[3]  # Ruta de salida para los resultados

# ───────────────────────────────
# 1. Cargar datos preprocesados
# ───────────────────────────────
cat("Cargando archivos de conteo...\n")

# Leer conteos de TFs
real_counts <- fread(real_counts_file, header = FALSE, col.names = c("ft_name", "n_seq_real"))
shuf_counts <- fread(shuf_counts_file, header = FALSE, col.names = c("ft_name", "n_seq_shuf"))

# Leer totales de secuencias únicas
n_total_real <- as.integer(readLines(total_real_file))
n_total_shuf <- as.integer(readLines(total_shuf_file))

# ───────────────────────────────
# 2. Fusionar y construir tablas 2x2
# ───────────────────────────────
cat("Fusionando conteos reales y permutados...\n")

merged <- merge(real_counts, shuf_counts, by = "ft_name", all = TRUE)

# Rellenar NAs con 0 (TFs no detectados en un conjunto)
merged[is.na(n_seq_real), n_seq_real := 0]
merged[is.na(n_seq_shuf), n_seq_shuf := 0]

# Calcular complementos para la tabla de contingencia
merged[, `:=`(
  n_not_real = n_total_real - n_seq_real,
  n_not_shuf = n_total_shuf - n_seq_shuf
)]

# ───────────────────────────────
# 3. Aplicar Fisher Test a cada TF
# ───────────────────────────────
cat("Aplicando Fisher Exact Test a", nrow(merged), "TFs...\n")

results <- merged[, {
  mat <- matrix(c(n_seq_real, n_not_real, n_seq_shuf, n_not_shuf), nrow = 2)
  test <- fisher.test(mat, alternative = "greater")  # Prueba unilateral para enriquecimiento
  
  list(
    n_seq_real = n_seq_real,
    n_seq_shuf = n_seq_shuf,
    odds_ratio = unname(test$estimate),
    p_value = test$p.value
  )
}, by = ft_name]

# ───────────────────────────────
# 4. Corrección múltiple (FDR)
# ───────────────────────────────
cat("Ajustando p-valores por FDR...\n")
results[, fdr := p.adjust(p_value, method = "fdr")]

# Ordenar por significancia
setorder(results, fdr, p_value)

# ───────────────────────────────
# 5. Exportar resultados
# ───────────────────────────────
cat("Guardando resultados en", output_csv, "...\n")
fwrite(results, output_csv)

# Resumen estadístico
cat("\n Análisis completado!\n")
cat("• TFs analizados:", nrow(results), "\n")
cat("• TFs significativos (FDR < 0.05):", sum(results$fdr < 0.05), "\n")
cat("• Top 3 TFs más enriquecidos:\n")
print(head(results[order(odds_ratio, decreasing = TRUE)], 3))

# Generar archivo adicional con TFs significativos
sig_results <- results[fdr < 0.05]
if (nrow(sig_results) > 0) {
  sig_file <- sub(".csv", "_significant.csv", output_csv)
  fwrite(sig_results, sig_file)
  cat("• TFs significativos guardados en:", sig_file, "\n")
}
