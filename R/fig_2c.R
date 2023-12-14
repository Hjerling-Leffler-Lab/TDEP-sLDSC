# = shuyang yao (20230125)
# = bar chart for top 10 Clusters for scz2022
# length of bar = -log10(P)
# proportion of bar: proportion in top 3 regions.

#--- script starts ---#

library(data.table)
library(tidyverse)
library(ggplot2)
library(scico)
library(here)

# read in SCZ cluster level results
df <- read_xlsx(here("data/supplemental-tables.xlsx"), sheet = "TableS8") |> 
  filter(Phenotype == "scz2022") |> 
  slice_min(P,  n = 25)


ggplot(
  df,
  aes(
    x = reorder(Cluster, -P.fdr),
    y = -log10(P),
    fill = -log10(P)
  )
) +
  geom_bar(stat = "identity") +
  coord_flip() +
  xlab("") +
  ylab(expression("-log"[10] * "(P)")) +
  labs(title = "Top Clusters (scz2022)") +
  theme_light() +
  theme(axis.title.x = element_text(hjust = 0)) +
  scico::scale_fill_scico(palette = "lajolla", midpoint = 5, direction = -1) +
  guides(fill = "none")


ggsave(
  file = "workflow/figures/2c.pdf",
  width = 5, height = 6
)
