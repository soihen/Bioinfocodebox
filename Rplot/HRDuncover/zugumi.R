library(tidyverse)
library(argparse)


#整体图
parser <- ArgumentParser(description = "plot uncover")
parser$add_argument('uncover', help = "The uncover file,e.g:chr1 1565648")
args <- parser$parse_args()

df<-read_tsv(args$uncover)

ggplot(df,aes(x = log10(uncover), fill = chr)) + geom_histogram(colour = "black")

dev.off()