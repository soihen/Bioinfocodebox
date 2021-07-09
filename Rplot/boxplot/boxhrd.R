library(tidyverse)
library(ggpubr)

#数据准备：过滤qc差的样本map95以下target，uniformot0.5X80%，mapping率三个指标过滤
#整体思路：CNR数据按(GENE)样本类型（石蜡，新鲜组织，胸腹水）分类，以每个位点为数据单位57*29151,160万个点
#最后画boxplot时，x=样本类型*tumor/normal，y=log2画图,如果点太多有需要可按照gene分页，facet_wrap(gene)
#kwtest检验，检验tumor和normal间log2的独立性(是否检验样本类型间的独立性？)
#这次不关心gene，不用清洗

setwd("\\\\172.16.11.242/test_data/CNV_enhance/HRDana/data/tumor/gdcnr")
t_cnr <- list.files(pattern = "*cnr")
t_coverage <- list()

i = 1
for (fname in t_cnr){
    cnr <- read_tsv(fname)
    cnr <- select(cnr,log2)
    cnr <- filter(cnr,log2 != 'NA')

    colnames(cnr) <- strsplit(fname, ".", fixed = T)[[1]][[1]]
    t_coverage[[i]] <- cnr
    i <- i + 1
}
tcov_df <- do.call(cbind, t_coverage)
tdf<-tcov_df %>% pivot_longer(1:19,names_to = 'sampleID', values_to = 'log2')

setwd("\\\\172.16.11.242/test_data/CNV_enhance/HRDana/data/normal/gdcnr")
n_cnr <- list.files(pattern = "*cnr")
n_coverage <- list()

i = 1
for (fname in n_cnr){
    cnr <- read_tsv(fname)
    cnr <- select(cnr,log2)
    cnr <- filter(cnr,log2 != 'NA')

    colnames(cnr) <- strsplit(fname, ".", fixed = T)[[1]][[1]]
    n_coverage[[i]] <- cnr
    i <- i + 1
}

ncov_df <- do.call(cbind, n_coverage)
ndf<-ncov_df %>% pivot_longer(1:38,names_to = 'sampleID', values_to = 'log2')

setwd("\\\\172.16.11.242/test_data/CNV_enhance/HRDana/data/tumor")

sampleinfo <- read_tsv('tumorsampleinfo.txt')
sampleinfo <- mutate(sampleinfo, sampleID = paste0(sampleID, "IG"))

tdf<-tdf %>% inner_join(sampleinfo, by = "sampleID")
ndf<-ndf %>% mutate(type = '全血')
df<-rbind(tdf,ndf)


ggplot(df,aes(x = type, y = log2)) + geom_boxplot()


####单个bin测试
setwd("\\\\172.16.11.242/test_data/CNV_enhance/HRDana/data/tumor/gdcnr")
t_cnr <- list.files(pattern = "*cnr")

tdf<-{}

for (fname in t_cnr){
    cnr <- read_tsv(fname)
    cnr <- cnr%>%select(chromosome,start,end,log2)
    cnr <- filter(cnr,log2 != 'NA')
    cnr <- mutate(cnr,sampleID=strsplit(fname, ".", fixed = T)[[1]][[1]])
    tdf<-rbind(tdf,cnr)
}

setwd("\\\\172.16.11.242/test_data/CNV_enhance/HRDana/data/normal/gdcnr")
n_cnr <- list.files(pattern = "*cnr")

ndf<-{}

for (fname in n_cnr){
    cnr <- read_tsv(fname)
    cnr <- cnr%>%select(chromosome,start,end,log2)
    cnr <- filter(cnr,log2 != 'NA')
    cnr <- mutate(cnr,sampleID=strsplit(fname, ".", fixed = T)[[1]][[1]])
    ndf<-rbind(ndf,cnr)
}

setwd("\\\\172.16.11.242/test_data/CNV_enhance/HRDana/data/tumor")

sampleinfo <- read_tsv('tumorsampleinfo.txt')
sampleinfo <- mutate(sampleinfo, sampleID = paste0(sampleID, "IG"))

tdf<-tdf %>% inner_join(sampleinfo, by = "sampleID")
ndf<-ndf %>% mutate(type = '全血')
df<-rbind(tdf,ndf)

df<-mutate(df,bin = paste0(chromosome,'.' ,start))

bin <- df %>%
    group_by(bin) %>%
    summarise(mean_log2 = mean(log2),
              std = sd(log2))


df<-df %>% inner_join(bin, by = "bin")

binsort<-bin %>% arrange(std)
bin12<-binsort[1:12,]
bin12<-bin12 %>% inner_join(df, by = "bin")
ggplot(bin12,aes(x = type ,color = type, y = log2)) + geom_boxplot()+ facet_wrap(~bin) +stat_compare_means(aes(x=type,y=log2))

#####HRD数据qc boxplot

setwd("\\\\172.16.11.242/test_data/CNV_enhance/HRDana/data")
sampleinfo <- read_tsv('HRDsampleinfo.txt')
colnames(sampleinfo) <- c("sampleID", "types")
sampleinfo <- mutate(sampleinfo, sampleID = paste0(sampleID, "IG.tumor"))


sampleinfo <- sampleinfo %>%
    mutate(types = if_else(startsWith(types, "石蜡"), "石蜡", types),
           types = if_else(startsWith(types, "新鲜"), "新鲜组织", types),
           types = if_else(startsWith(types, "胸"), "胸腹水", types))

tdf <- read_tsv('tumor/qc/tumorqc.csv')
tdf <- tdf%>%inner_join(sampleinfo,by='sampleID')

ndf <- read_tsv('normal/qc/normalqc.csv')
ndf <- ndf%>%mutate(types='全血')
df <- rbind(tdf,ndf)

df<-df %>% pivot_longer(2:4,names_to = 'name', values_to = 'values')



ggplot(df,aes(x = name ,color = types, y = values)) + geom_boxplot()
