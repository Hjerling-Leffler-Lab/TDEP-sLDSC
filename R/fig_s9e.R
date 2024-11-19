library(data.table)
library(here)
library(ggplot2)

df <- fread(here("data/data1_heatmap.matrix.tsv"))

pdf(file=paste(plotdir,"workflow/figures/fig9e_connections_FI_sum_across_folds.pdf",sep=""), height = 10, width = 12)
heatmap(as.matrix(mymx), scale="none")
dev.off()
