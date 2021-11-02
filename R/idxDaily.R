#!/usr/bin/env Rscript
library(optparse)

option_list = list(
  make_option(c("-e", "--emiten"), type="character", default=NULL, 
              help="emiten name", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="emiten.csv", 
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
#print(head(emiten, 5))
dataset = data.frame(emiten)
dataset$date = rownames(dataset)
dataset$emiten = opt$e
#print(head(dataset, 5))
names(dataset) = c('Open','High','Low','Close','Volume','Adjusted',
                   'Date','Emiten')
dataset = dataset[,c('Open','High','Low','Close','Volume','Date','Emiten')]
write.csv(dataset, file=opt$o, row.names = FALSE)
