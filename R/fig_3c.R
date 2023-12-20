# fig_3c.R
# Fig 3C: CC of the GO terms of the top 10% specifically expressed genes in the top 25 clusters

library(data.table)
library(tidyverse)
library(rrvgo)

#- read in GSA results
dat <- fread(here("workflow/gsa_cluster_SCZtop25.tsv.gz"))

#- get score from enrichment
scores.top25 <- setNames(-log10(dat$P.fdr.group), dat$ID)

#- get similarity matrix, for BP, CC, and MF separately
simMatrix.top25.CC <- calculateSimMatrix(dat$ID,
                                         orgdb="org.Hs.eg.db",
                                         ont=c("CC"),
                                         method="Rel")

# input of plots
reducedTerms.top25.CC <- reduceSimMatrix(simMatrix.top25.CC,
                                         scores.top25,
                                         threshold=0.7,
                                         orgdb="org.Hs.eg.db")

# plot
pdf(file = here("workflow/figures/3c_treeMapCC_SCZtop25.pdf"))
treemapPlot(reducedTerms.top25.CC)
dev.off()

#--- end ---# 
