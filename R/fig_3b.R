# fig_3b.R
# top 25 clusters for scz2022

library(data.table)
library(tidyverse)
library(ggplot2)
library(scico)
library(here)

# read in SCZ cluster level results
df <- read_xlsx(here("data/supplemental-tables.xlsx"), sheet = "TableS8") |> 
  filter(Phenotype == "scz2022") |> 
  slice_min(P,  n = 25)


p <- ggplot(
  df,
  aes(
    x = reorder(Cluster, -P.fdr),
    y = -log10(P),
    fill = -log10(P)
  )
) +
  geom_bar(stat = "identity") +
  coord_flip() +
  xlab("") + ylab(expression('-log'[10]*'(P)')) +
  labs(title="Top Clusters (scz2022)") +
  theme_light() + theme(axis.title.x=element_text(hjust=0)) +
  scico::scale_fill_scico(palette = "lajolla", midpoint = 5) +
  guides(fill="none")

ggsave(p,
  file = here("workflow/figures/3b_topClusters_scz.pdf"),
  width = 5, height = 6
)

