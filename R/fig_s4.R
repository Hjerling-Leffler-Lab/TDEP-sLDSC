library(tidyverse)
library(data.table)
library(rstatix)
library(skimr)
library(here)
library(umap)
library(dbscan)
library(ggrepel)
library(ggExtra)


#   umap code in 13-supercluster-tdep.R
#   A = elements are TDEP 0/1
#   B = elements are log2(TPM+1)
#=== umap :: tdep :: tdep-umap.png (tag is A)
# restart point
c <- fread(here("data", "tdep-umap-data.tsv"))
 
ggplot(c, aes(X1, X2)) + 
  geom_point(aes(colour=factor(cluster)), size=2) +
  geom_text_repel(aes(label=Supercluster_ID), size=3, max.overlaps = 20) +
  labs(tag="A", x="umap1", y="umap2") +
  theme_classic() + theme(legend.position="none", aspect.ratio=0.8)
ggsave("workflow/figures/s4a.png", height = 8, width = 8)



#=== umap :: log2(tpm+1) :: tpm-umap.png (tag is B)
c <- fread(here("data", "tpm-umap-data.tsv"))


ggplot(c, aes(X1, X2)) + 
  geom_point(aes(colour=factor(cluster)), size=2) +
  geom_text_repel(aes(label=Supercluster_ID), size=3, max.overlaps = 20) +
  labs(tag="B", x="umap1", y="umap2") +
  theme_classic() + theme(legend.position="none", aspect.ratio=0.8)
ggsave("workflow/figures/s4b.png", height = 8, width = 8)
