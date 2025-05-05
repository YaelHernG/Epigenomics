#!/usr/bin/env Rscript

#------------------------------------------





#-------------------------------------------

library(data.table)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 3) {
  stop("Usage: Rscript fisher_test_TFs.R promoters_real.tsv promoters_shuffled.tsv output_results.csv")
}

real_file <- args[1]
shuff_file <- args[2]
output_csv <- args[3]

# ───────────────────────────────
# 1. Leer columnas necesarias
# ───────────────────────────────
cols_needed <- c("seq_id", "ft_name")
dt_real <- fread(real_file, select = cols_needed)
dt_shuf <- fread(shuff_file, select = cols_needed)

# ───────────────────────────────
# 2. Contar por TF en cada dataset
# ───────────────────────────────
dt_real_unique <- unique(dt_real)
dt_shuf_unique <- unique(dt_shuf)

real_counts <- dt_real_unique[, .(n_seq_real = uniqueN(seq_id)), by = ft_name]
shuf_counts <- dt_shuf_unique[, .(n_seq_shuf = uniqueN(seq_id)), by = ft_name]

n_total_real <- uniqueN(dt_real_unique$seq_id)
n_total_shuf <- uniqueN(dt_shuf_unique$seq_id)

# ───────────────────────────────
# 3. Fusionar y construir tablas 2x2
# ───────────────────────────────
merged <- merge(real_counts, shuf_counts, by = "ft_name", all = TRUE)
merged[is.na(n_seq_real), n_seq_real := 0]
merged[is.na(n_seq_shuf), n_seq_shuf := 0]

merged[, `:=`(
  n_not_real = n_total_real - n_seq_real,
  n_not_shuf = n_total_shuf - n_seq_shuf
)]

# ───────────────────────────────
# 4. Fisher Test por TF
# ───────────────────────────────
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
results[, fdr := p.adjust(p_value, method = "fdr")]

# ───────────────────────────────
# 6. Exportar resultado
# ───────────────────────────────
fwrite(results, output_csv)

cat("✅ Análisis completado. Resultado en", output_csv, "\n")
