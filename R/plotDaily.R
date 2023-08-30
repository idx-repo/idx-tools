#!/usr/bin/env Rscript
library(optparse)

option_list = list(
  make_option(c("-e", "--emiten"), type="character", default=NULL, 
              help="emiten name", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="emiten.PNG", 
              help="output file name [default= %default]", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)
# Cek
#print(opt$e)
#print(opt$o)

# library
library(quantmod)
# get data
emiten = getSymbols(paste(opt$e, "JK", sep="."),
                    src='yahoo', auto.assign=FALSE) 
# plot
subset=paste(Sys.Date()-(365*2), Sys.Date(), sep='/')
png(file=opt$o, width=1024, height=768)
candleChart(emiten, type='candlesticks', subset=subset, name=opt$e,
            TA=c(addMACD(), addRSI(), addVo(), addBBands()))
dev.off()
