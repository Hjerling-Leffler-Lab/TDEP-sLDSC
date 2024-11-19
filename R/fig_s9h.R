library(data.table)
library(here)
library(ggplot2)

df <- fread(here("data/data1_AHfeature_top_n_FI.tsv"))

p <- ggplot(myout1 %>% mutate(p_AH2=ifelse(top_n_roi<=5700,p_AH,NA)),
             aes(x=top_n_roi, y=-log10(p_AH2))) +
  geom_line() +
  geom_point(size=.2) +
  geom_hline(yintercept = -log10(0.05/nrow(myout1)),
             linetype="dashed") +
  theme_classic() +
  ylab(expression('-log' [10] * '(P-enrichment)')) + xlab("Top n connections") +
  ylim(c(0,16))

pdf(file=here("workflow/figures/figs9h_AHenrichment_P_top_n_FI.pdf"), height = 2, width = 5)
p
dev.off()