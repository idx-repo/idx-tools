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
              help = "Output PNG file path [default: <CODE>.png]", metavar = "FILE"),
  make_option(c("-d", "--days"), type = "integer", default = 730,
              help = "Number of past days to plot [default: %default]", metavar = "DAYS"),
  make_option(c("-v", "--verbose"), action = "store_true", default = FALSE,
              help = "Print detailed progress messages")
)

opt_parser <- OptionParser(
  option_list = option_list,
  usage = "Usage: %prog -e <EMITEN_CODE> [options]",
  description = "Generate candlestick chart with technical indicators (MACD, RSI, Volume, Bollinger Bands)."
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
out_file <- if (is.null(opt$out) || nchar(trimws(opt$out)) == 0) paste0(ticker, ".png") else opt$out

if (opt$verbose) {
  cat(sprintf("Fetching data for %s (symbol: %s)...\n", ticker, symbol))
}

data <- tryCatch({
  getSymbols(symbol, src = 'yahoo', auto.assign = FALSE)
}, error = function(e) {
  cat(sprintf("Error: Failed to fetch data for ticker '%s': %s\n", ticker, e$message), file = stderr())
  quit(status = 2)
})

subset_period <- paste(Sys.Date() - opt$days, Sys.Date(), sep = '/')

if (opt$verbose) {
  cat(sprintf("Generating plot for period %s into '%s'...\n", subset_period, out_file))
}

png(file = out_file, width = 1024, height = 768)
candleChart(data, type = 'candlesticks', subset = subset_period, name = ticker,
            TA = c(addMACD(), addRSI(), addVo(), addBBands()))
dev.off()

if (opt$verbose) {
  cat(sprintf("Chart saved to '%s'.\n", out_file))
}
