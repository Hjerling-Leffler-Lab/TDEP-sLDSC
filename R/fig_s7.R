# fig_s7.R
# Fig S7: BP (s7a) and MF (s7b) of the GO terms of the top 10% specifically expressed genes in the top 25 clusters

library(data.table)
library(tidyverse)
library(rrvgo)

#- read in GSA results
dat <- fread(here("data/gsa_cluster_SCZtop25.tsv"))

#- get score from enrichment
scores.top25 <- setNames(-log10(dat$P.fdr.group), dat$ID)

#- get similarity matrix, for BP, CC, and MF separately
simMatrix.top25.BP <- calculateSimMatrix(dat$ID,
                                         orgdb="org.Hs.eg.db",
                                         ont=c("BP"),
                                         method="Rel")
simMatrix.top25.MF <- calculateSimMatrix(dat$ID,
                                         orgdb="org.Hs.eg.db",
                                         ont=c("MF"),
                                         method="Rel")

# input of plots
reducedTerms.top25.BP <- reduceSimMatrix(simMatrix.top25.BP,
                                         scores.top25,
                                         threshold=0.7,
                                         orgdb="org.Hs.eg.db")
reducedTerms.top25.MF <- reduceSimMatrix(simMatrix.top25.MF,
                                         scores.top25,
                                         threshold=0.7,
                                         orgdb="org.Hs.eg.db")
# plot
pdf(file = here("workflow/figures/s7a_treeMapBP_SCZtop25.pdf"))
treemapPlot(reducedTerms.top25.BP)
dev.off()
pdf(file = here("workflow/figures/s7b_treeMapMF_SCZtop25.pdf"))
treemapPlot(reducedTerms.top25.MF)
dev.off()

#--- end ---# 
