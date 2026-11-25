#!/usr/bin/env Rscript

# Check for required optparse package
if (!suppressWarnings(require("optparse", quietly = TRUE))) {
  cat("Error: Required R package 'optparse' is not installed.\n", file = stderr())
  cat("Please install dependencies with: Rscript R/install-deps.R\n", file = stderr())
  quit(status = 1)
}

option_list <- list(
  make_option(c("-e", "--emiten"), type = "character", default = NULL,
              help = "Emiten ticker code (e.g. BBCA, TLKM) [required]", metavar = "CODE"),
  make_option(c("-o", "--out"), type = "character", default = NULL,
              help = "Output CSV file path [default: <CODE>.csv]", metavar = "FILE"),
  make_option(c("-s", "--src"), type = "character", default = "yahoo",
              help = "Data source [default: %default]", metavar = "SOURCE"),
  make_option(c("-v", "--verbose"), action = "store_true", default = FALSE,
              help = "Print detailed progress messages")
)

opt_parser <- OptionParser(
  option_list = option_list,
  usage = "Usage: %prog -e <EMITEN_CODE> [options]",
  description = "Download daily stock price data for an IDX emiten from Yahoo Finance."
)

opt <- parse_args(opt_parser)

if (is.null(opt$emiten) || nchar(trimws(opt$emiten)) == 0) {
  cat("Error: Option --emiten (-e) is required.\n\n", file = stderr())
  print_help(opt_parser)
  quit(status = 1)
}

# Check for quantmod package
if (!suppressWarnings(require("quantmod", quietly = TRUE))) {
  cat("Error: Required R package 'quantmod' is not installed.\n", file = stderr())
  cat("Please install dependencies with: Rscript R/install-deps.R\n", file = stderr())
  quit(status = 1)
}

ticker <- trimws(toupper(opt$emiten))
symbol <- paste(ticker, "JK", sep = ".")
out_file <- if (is.null(opt$out) || nchar(trimws(opt$out)) == 0) paste0(ticker, ".csv") else opt$out

if (opt$verbose) {
  cat(sprintf("Fetching data for %s (symbol: %s) from source '%s'...\n", ticker, symbol, opt$src))
}

data <- tryCatch({
  getSymbols(symbol, src = opt$src, auto.assign = FALSE)
}, error = function(e) {
  cat(sprintf("Error: Failed to fetch data for ticker '%s': %s\n", ticker, e$message), file = stderr())
  quit(status = 2)
})

dataset <- data.frame(data)
dataset$date <- rownames(dataset)
dataset$emiten <- ticker

names(dataset) <- c('Open', 'High', 'Low', 'Close', 'Volume', 'Adjusted', 'Date', 'Emiten')
dataset <- dataset[, c('Open', 'High', 'Low', 'Close', 'Volume', 'Date', 'Emiten')]

write.csv(dataset, file = out_file, row.names = FALSE)

if (opt$verbose) {
  cat(sprintf("Successfully written %d records to '%s'.\n", nrow(dataset), out_file))
}
