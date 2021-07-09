library(tidyverse)
library(patchwork)
#library(cowplot)

#按染色体划分图
#不均匀坐标轴的两种方式：1：取对数 2：对不同区间的统计量进行统计，注意应改为str


#读取五家公司的数据
cleantwist<-read_tsv('/public/home/hw/temp/HRDbed/data/bychr/cleantwist.uncover.txt')
heyin<-read_tsv('/public/home/hw/temp/HRDbed/data/bychr/heyin.uncover.txt')
igenetech<-read_tsv('/public/home/hw/temp/HRDbed/data/bychr/igenetech.uncover.txt')
nanodigm<-read_tsv('/public/home/hw/temp/HRDbed/data/bychr/nanodigm.uncover.txt')
roche<-read_tsv('/public/home/hw/temp/HRDbed/data/bychr/roche.uncover.txt')

df<-{}

dfn <- cleantwist %>% tidyr!na::pivot_longer(cols = !chr, names_to = c("panel", ".value"), names_pattern = "(.*)_(.*)")
df<-rbind(df,dfn)
dfn <- heyin %>% tidyr::pivot_longer(cols = !chr, names_to = c("panel", ".value"), names_pattern = "(.*)_(.*)")
df<-rbind(df,dfn)
dfn <- igenetech %>% tidyr::pivot_longer(cols = !chr, names_to = c("panel", ".value"), names_pattern = "(.*)_(.*)")
df<-rbind(df,dfn)
dfn <- nanodigm %>% tidyr::pivot_longer(cols = !chr, names_to = c("panel", ".value"), names_pattern = "(.*)_(.*)")
df<-rbind(df,dfn)
dfn <- roche %>% tidyr::pivot_longer(cols = !chr, names_to = c("panel", ".value"), names_pattern = "(.*)_(.*)")
df<-rbind(df,dfn)


#由于有的panel没有XY染色体，且XY位点太少，故不统计

dfp<-subset(df, panel=='cleantwist')
plot1<-ggplot(dfp,aes(x = log10(uncover), fill = panel)) + geom_histogram(colour = "black") + facet_wrap(~ chr)
ggsave(plot1, file = "twistsum.pdf")

dfp<-subset(df, panel=='heyin')
plot1<-ggplot(dfp,aes(x = log10(uncover), fill = panel)) + geom_histogram(colour = "black") + facet_wrap(~ chr)
ggsave(plot1, file = "heyinsum.pdf")

dfp<-subset(df, panel=='igenetech')
plot1<-ggplot(dfp,aes(x = log10(uncover), fill = panel)) + geom_histogram(colour = "black") + facet_wrap(~ chr)
ggsave(plot1, file = "igenetechsum.pdf")

dfp<-subset(df, panel=='nanodigm')
plot1<-ggplot(dfp,aes(x = log10(uncover), fill = panel)) + geom_histogram(colour = "black") + facet_wrap(~ chr)
ggsave(plot1, file = "nanodigmsum.pdf")

dfp<-subset(df, panel=='roche')
plot1<-ggplot(dfp,aes(x = log10(uncover), fill = panel)) + geom_histogram(colour = "black") + facet_wrap(~ chr)
ggsave(plot1, file = "rochesum.pdf")


# plot2<-list()
#
#
# for (chrom in seq(1,22)){
#   nos<-paste0("chr", chrom)
#   dfchr<-subset(df, chr==nos&panel=='roche')
#   p<-ggplot(data = dfchr,aes(x = log10(uncover), fill = panel)) + geom_histogram(colour = "black") + ggtitle(nos)
#   plot2[[chrom]] <- p
#  }
#
#
# dev.off()
#plots<-p[[1]]/p[[2]]/p[[3]]/p[[4]]/p[[5]]/p[[6]]/p[[7]]/p[[8]]/p[[9]]/p[[10]]/p[[11]]/p[[12]]/p[[13]]/p[[14]]/p[[15]]/p[[16]]/p[[17]]/p[[18]]/p[[19]]/p[[20]]/p[[21]]/p[[22]]

# nos<-paste0("chr", 1)
# dfchr<-subset(df, chr==nos)
# res_plot <- ggplot(dfchr,aes(x = log10(uncover), fill = panel)) + geom_histogram(colour = "black") + ggtitle(nos)
# for (chrom in seq(2,22)){
#   nos<-paste0("chr", chrom)
#   dfchr<-subset(df, chr==nos)
#   temp_plot <- ggplot(dfchr,aes(x = log10(uncover), fill = panel)) + geom_histogram(colour = "black") + ggtitle(nos)
#   res_plot <- plot_grid(res_plot, temp_plot, align="h")
# }