# fig_5c.R
#- Fig5C_fMRI_region_nEdge.R

library(data.table)
library(tidyverse)

df.hist.edge <- fread(here("data/df5c.hist.edge.tsv"))

p <- ggplot(df.hist.edge %>% slice_max(order_by=n_edges, n=20),
            aes(x=reorder(Region1,n_edges), y=n_edges, fill=regions2)) +
  geom_bar(stat="identity",width = .8) +
  coord_flip() +
  xlab("Regions") + ylab("Nr. valid connections in models with AUC>0.5") +
  theme_classic() +
  guides(fill=guide_legend(title=""))

pdf(file=here("workflow/figures/5c_hist_top20_nEdges_AUCgt0.5.pdf"), height = 3, width = 4)
p
dev.off()
