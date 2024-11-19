library(data.table)
library(here)
library(ggplot2)

df <- fread(here("data/data1_df.mod_AUC_Acc_group_ref.tsv"))

p1 <- ggplot(df.mod,
             aes(x=Run,y=AUC, color=as.character(fold), 
                 shape=group, 
             )) +
  geom_point() +
  stat_smooth(method="loess", formula=y~x, alpha=.1, size=.5) +
  theme_classic() +
  guides(color="none") +
  geom_hline(yintercept = 0.5, color="darkgrey", linetype="dashed") +
  facet_wrap(~fold, nrow=1)


pdf(file=here("workflow/figures/figs9a_AUC_all.pdf"), height = 3, width = 4)
p1
dev.off()