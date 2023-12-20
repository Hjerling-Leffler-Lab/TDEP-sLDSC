# fig_5b.R
# Fig5B: fMRI, region by number of appearance (number of Models)

library(data.table)
library(tidyverse)
library(here)

df.hist.region <- fread(here("data/df5b.hist.region.tsv"))

p <- ggplot(df.hist.region %>% slice_max(order_by=n_model, n=20),
            aes(x=reorder(Region1,n_model), y=n_model, fill=regions2)) +
  geom_bar(stat="identity",width = .8) +
  coord_flip() +
  xlab("Regions") + ylab("Freq. observed in models with AUC>0.5") +
  theme_classic() +
  guides(fill=guide_legend(title=""))

pdf(file=here("workflow/figures/5b_hist_top20_nModels_AUCgt0.5.pdf"), height = 3, width = 4)
p
dev.off()
