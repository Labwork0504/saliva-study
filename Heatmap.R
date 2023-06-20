library(ComplexHeatmap)
library(psych)
library(pheatmap)
library(circlize)
library(tidyverse)

getwd()
setwd("")
df1 <- read.table("13. factorfinal.txt",row.names = 1) %>%t() %>%
  as_tibble() %>%  column_to_rownames("Factor") %>% mutate(across(where(is.character),as.numeric))  
df2 <-
  read.table("13. AAA53 50genus.txt", sep = "\t",row.names = 1) %>% t() %>% 
  as_tibble() %>%  column_to_rownames("Taxon") %>% mutate(across(where(is.character),as.numeric))  
cor <- corr.test(df2, df1, method = "spearman",adjust="BH")
cmt <-cor$r
pvalue <- cor$p %>%as.data.frame() %>% mutate_all(~case_when(. >= 0.05 & . < 0.1 ~ "#",
                                                           . >=0.01& .<0.05~ "*",
                                                           . < 0.01 ~ "**",
                                                           . < 0.001 ~ "***",
                                                           TRUE ~ "")) %>% as.matrix()
col_fun = colorRamp2(c(-0.4, 0, 0.4),
                     c("#0072B5FF", "white", "#BC3C29FF"))
col_fun(seq(-3, 3))
Heatmap(cmt,
        name = " ", 
        col = col_fun,
        column_names_side = "bottom" ,
      
        show_column_dend = T,
        #cluster_rows = FALSE,
        cluster_columns = FALSE,
        column_names_rot = 45,
        row_names_gp = gpar(fontsize = 11, col="black"),
        column_names_gp  = gpar(fontsize = 11, col="black"),
        cell_fun = function(j, i, x, y, width, height, fill) {
          grid.text(pvalue[i, j], x, y, gp = gpar(fontsize = 10))},
        rect_gp = gpar(lwd = 0,col = "white"),
        width = unit(8/1.2, "cm"),
        height = unit(83.2/3, "cm")
)

