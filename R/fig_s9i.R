library(data.table)
library(here)
library(ggplot2)

df <- fread(here("data/data2cobre_AHfeature_top_n_FI.tsv"))

p <- ggplot(myout1,aes(x=top_n_roi, y=pct_AHroi)) +
  geom_line() +
  geom_point(size=.2) +
  geom_hline(yintercept = nrow(df.fi.sum.sum %>% filter(AmygHipp==1))/nrow(df.fi.sum.sum),
             linetype="dashed") +
  theme_classic() +
  xlab("Top n connections") +
  ylab("Prop. Amyg./Hipp. connections ") +
  ylim(c(0,1))

pdf(file=here("workflow/figures/figs9i_pctAH_top_n_FI.pdf"), height = 2, width = 5)
p
dev.off()