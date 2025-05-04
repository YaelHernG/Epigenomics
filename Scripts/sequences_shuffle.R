#!/usr/bin/env Rscript

# -----------------------------------------------
# Genera secuencias permutadas desde un archivo FASTA
# Mantiene longitud y composición global (shuffle por k-mer)
# Autor: [Tu nombre]
# -----------------------------------------------

suppressPackageStartupMessages({
  library(Biostrings)
})

# ------------ 1. Entrada de argumentos ----------------
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 3) {
  cat("Uso: Rscript shuffle_fasta.R <input.fa> <output.fa> <kmer_size>\n")
  quit(status = 1)
}

input_file <- args[1]       # FASTA de entrada
output_file <- args[2]      # FASTA de salida
kmer_size <- as.integer(args[3])  # tamaño de k-mer a conservar

set.seed(42) # reproducibilidad

# ------------ 2. Función de permutación ---------------
shuffle_sequence <- function(seq, k) {
  seq <- toupper(as.character(seq))
  nucs <- strsplit(seq, "")[[1]]
  
  if (k <= 1) {
    return(paste(sample(nucs), collapse = ""))
  } else {
    kmers <- substring(seq, seq(1, nchar(seq) - k + 1, by = k), seq(k, nchar(seq), by = k))
    shuffled_kmers <- sample(kmers)
    return(paste(shuffled_kmers, collapse = ""))
  }
}

# ------------ 3. Leer FASTA ---------------------------
cat("Leyendo archivo:", input_file, "...\n")
sequences <- readDNAStringSet(input_file)

# ------------ 4. Aplicar permutación ------------------
cat("Generando permutaciones...\n")
shuffled_seqs <- DNAStringSet(
  sapply(as.character(sequences), shuffle_sequence, k = kmer_size)
)
names(shuffled_seqs) <- names(sequences)

# ------------ 5. Guardar resultado --------------------
cat("Guardando resultado en:", output_file, "\n")
writeXStringSet(shuffled_seqs, output_file)

# ------------ 6. Reporte básico ------------------------
cat("\n=== Reporte de Calidad ===\n")
cat("Total de secuencias:", length(sequences), "\n")
cat("Longitud promedio original:", round(mean(width(sequences))), "bp\n")
cat("Longitud promedio permutada:", round(mean(width(shuffled_seqs))), "bp\n")

# Comparación opcional de k-mer
if (kmer_size > 1) {
  cat("\nComparando k-mers en una secuencia aleatoria...\n")
  sample_seq <- sample(length(sequences), 1)
  original_kmers <- oligonucleotideFrequency(sequences[[sample_seq]], width = kmer_size)
  shuffled_kmers <- oligonucleotideFrequency(shuffled_seqs[[sample_seq]], width = kmer_size)
  print(head(cbind(Original = original_kmers, Permutado = shuffled_kmers)))
}

cat("\n✔️  Proceso completado.\n")

