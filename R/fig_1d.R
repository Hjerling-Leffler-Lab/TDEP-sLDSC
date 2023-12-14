library(data.table)
library(tidyverse)
library(ggridges)
library(viridis)
library(hrbrthemes)



dat.ridgeline <- read_tsv(here("data/df.ridgeline2.scz2022FDR.tsv.gz"))

tmp <- dat.ridgeline %>%
  distinct(Supercluster, mean_tmp, frac_top_cons) %>%
  arrange(mean_tmp)
top.8quantile <- 0.741 # 80% quartile for fracCdsPhylopAm from original dataset (without intersecting with top specific genes)

ggplot(
  data = dat.ridgeline,
  aes(
    y = reorder(Supercluster, frac_top_cons),
    x = fracCdsPhylopAm,
    fill = -log10(scz2022_P.fdr)
  )
) +
  geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01) +
  scale_fill_gradient(name = expression("-log"[10] * "FDR"), low = "white", high = "blue") +
  labs(
    title = "Constraint in top specific genes",
    subtitle = "per Supercluster" # ,
    # caption = "Right column: proportion of the most constriant genes (in top 20%) per supercluster.\nColored by significance of enrichment of scz2022 GWAS."
  ) +
  ylab("") +
  xlab("Per gene, fraction of constraint bases") +
  theme(panel.background = element_rect(fill = "transparent")) +
  geom_vline(xintercept = top.8quantile, linetype = "dashed", color = "grey") +
  annotate(
    geom = "text",
    x = 1.1, y = tmp$Supercluster,
    label = round(tmp$frac_top_cons, 2),
    color = "darkgrey"
  ) +
  annotate(
    geom = "text",
    x = 1.05, y = 32,
    label = "Proportion",
    color = "darkgrey"
  ) +
  scale_x_continuous(
    limits = c(0, 1.1),
    breaks = c(0, 0.5, 1)
  )




ggsave(
  file = "workflow/figures/1c.pdf",
  width = 7.5, height = 6
)
