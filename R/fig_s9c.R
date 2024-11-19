library(data.table)
library(here)
library(ggplot2)

df <- fread(here("data/data1_regions_boxplot.tsv"))

p <- ggplot(df, aes(x=Region,y=Run)) +
  geom_boxplot(aes(fill=regions2,alpha=regions2),outlier.shape = NA,size=0.2) +
  coord_flip() +
  geom_jitter(color="black",size=.3,alpha=.7)+
  theme_classic() +
  scale_fill_manual(values=my_regions2_color)+
  scale_alpha_manual(values=c(1,.5,.5,1))+
  guides(alpha="none") 


pdf(file=here("workflow/figures/figs9c_regions_boxplot.pdf"), height = 3, width = 4)
p
dev.off()