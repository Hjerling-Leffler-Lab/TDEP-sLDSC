# fig_5d.R
#- Fig5d: top 14 (0.5%) connections to plot

library(data.table)
library(tidyverse)

df <- fread(here("data/df.S8e.heatmap.matrix.tsv")) 
df$Region1 <- colnames(df)
df <- df %>% 
  pivot_longer(cols=-Region1, names_to="Region2", values_to = "edge_strength")
df1 <- df %>%
  slice_max(order_by=edge_strength, prop=0.005) %>%
  group_by(edge_strength) %>%
  slice(n=1) %>%
  ungroup()

fwrite(df1, file=here("workflow/figures/5d_topEdges.tsv"),
       sep="\t", col.names = T)

#--- end ---#