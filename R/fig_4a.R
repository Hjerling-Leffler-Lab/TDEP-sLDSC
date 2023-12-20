# filename: fig_4a.R
# Fig4A: heatmap of the composition of clusters in each dissection
# clusters are grouped into superclsuters and dissections are grouped into regions

library(data.table)
library(tidyverse)
library(ggplot2)
library(here)

#- read data, correct region names
df <- fread(here("data/df_heatmap_cluster_roi_pct_Ncell_shortnames.tsv")) 

#- set order for region names
source(here("R/order_data.R"))

#- plot
# make into diciles inside ggplot
p.hm1 <- ggplot(df %>%
                  mutate(ff = pct_cluster_per_roi,
                         gg = ifelse(ff==0, NA, ff),
                         hh = ntile(gg, 10),     # this should not include NAs (checked and confirmed in the data frame)
                         newAlpha=hh*0.1),
                aes(x=reorder(as.character(Cluster_ID2),-Cluster_ID2), y=roi, fill=Supercluster, alpha=newAlpha)) +
  geom_tile() +
  theme_classic() +
  xlab("Cluster")+ylab("Dissection")+
  facet_grid(fct_relevel(regions2,order_regions)~fct_relevel(Supercluster2,order_ct3), 
             scales = "free", 
             space = "free",
             switch = 'y') + 
  guides(fill="none") +
  guides(alpha=guide_legend(title="Decile of cluster% \nper dissection")) +
  theme(axis.text.x=element_text(angle=90,hjust=1, vjust=.5,size=6),
    axis.text.y=element_text(size=7.5)) 

ggsave(p.hm1,
       file=here("workflow/figures/4a_heatmap_pct_cluster_roi_shortName.pdf"),
       width=33, height=12, limitsize = FALSE)

#-- end --#