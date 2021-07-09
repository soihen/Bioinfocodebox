library(tidyverse)
library(pheatmap)
library(janitor)


setwd("\\\\172.16.11.242/test_data/CNV_enhance/cnvkat/data/cnr")
cnn_files <- list.files(pattern = "*cnn")


coverage <- list()

i = 1
for (fname in cnn_files){
    cnn <- read_tsv(fname) %>%
        as.data.frame() %>%
        filter(gene != ".")
    
    cnn <- cnn[cnn$gene %in% cnn$gene[duplicated(cnn$gene)], ] %>%
        mutate(rows = paste0(gene, "_", row_number())) %>%
        select(rows, log2)
    rownames(cnn) <- cnn$rows
    cnn <- select(cnn, log2)
    
    colnames(cnn) <- strsplit(fname, ".", fixed = T)[[1]][[1]]
    coverage[[i]] <- cnn
    i <- i + 1
}

coverage_df <- do.call(cbind, coverage)
write.table(coverage_df, file = "../../concat_cnn.tsv", sep="\t", row.names = T)


pca <- prcomp(coverage_df2)



coverage_df2 <- coverage_df %>%
    # select(-ends_with("-0CF")) 
    filter(!is.na(`NGS0515-1CF`)) %>%
    # filter_all(all_vars(. > -2 & . < 2)) %>%
    identity()


plot <- pheatmap(as.matrix(coverage_df2),
                 cluster_rows = F)


save_pheatmap_pdf <- function(x, filename, width=7, height=7) {
    stopifnot(!missing(x))
    stopifnot(!missing(filename))
    pdf(filename, width=width, height=height)
    grid::grid.newpage()
    grid::grid.draw(x$gtable)
    dev.off()
}

save_pheatmap_pdf(plot, "cnn.pdf", 200, 35)



# ------------------------------- # 
all_cnrs <- read_tsv("./concat_cnr.tsv")
metrics <- read_tsv("../metrics.txt")
sampleinfo <- read_tsv("../sample_info.txt", col_names = F)
colnames(sampleinfo) <- c("sampleID", "types")
sampleinfo <- mutate(sampleinfo, sampleID = paste0(sampleID, "CF"))


sampleinfo <- sampleinfo %>%
    mutate(types = if_else(startsWith(types, "石蜡"), "石蜡", types),
           types = if_else(startsWith(types, "新鲜"), "新鲜组织", types),
           types = if_else(startsWith(types, "胸"), "胸腹水", types))
    # group_by(types) %>%
    # summarise(n = n())


norms <- metrics %>%
    filter(stdev < 3 ) %>%
    pull(sample)


data <- all_cnrs %>%
    t() %>%
    as.data.frame() %>%
    row_to_names(row_number = 1) %>%
    rownames_to_column(var = "sampleID") %>%
    pivot_longer(cols = MTOR_1: last_col(),
                 names_to = "genes",
                 values_to = "log2") %>%
    mutate(log2 = as.character(log2)) %>%
    mutate(log2 = replace_na(log2, -2)) %>%
    mutate(log2 = as.double(log2)) %>%
    mutate(gene = gsub("_\\d+", "", genes)) %>%
    inner_join(sampleinfo, by = "sampleID") %>%
    as_tibble() 


 
data %>%
    # distinct(sampleID) %>%
    group_by(gene) %>%
    summarise(mean = mean(log2),
              std = sd(log2),
              n = n()) %>%
    View()


library(ggpubr)


data %>%
    filter(types != "test") %>%
    filter(grepl("NTRK2", genes)) %>%
    # filter(log2 > -2) %>%
    ggplot(mapping = aes(x = genes, y = log2, color = types)) + 
    geom_boxplot() +
    geom_jitter(position = position_dodge(width = .75)) +
    theme(axis.text.x = element_text(angle = 90)) +
    stat_compare_means()


ggsave("all_genes_log2.jpg", last_plot(), width = 50, height = 50, limitsize = F)


