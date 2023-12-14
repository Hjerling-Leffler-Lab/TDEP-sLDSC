library(tidyverse)
library(here)

# stored as RDS to retain factor format
load(here("data/genetic_correlations.rds"))
load(here("data/h2_data.rds"))


plotdata %>%
  ggplot(aes(x = pheno1, y = pheno2, fill = rg)) +
  geom_tile() +
  geom_text(aes(label = sig_label), size = 3) +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", limits = c(-1, 1)) +
  theme(
    text = element_text(size = 13),
    axis.text.x = element_text(angle = 40, hjust = 1),
    panel.grid.major = element_blank(),
    panel.background = element_rect(fill = "lightgray"),
  ) +
  labs(
    x = "",
    y = "",
    fill = bquote(r[g])
  ) +
  facet_grid(~disorder_type, scales = "free", space = "free") +
  geom_text(data = h2, aes(pheno1, pheno2, label = sig_label), size = 1.8)




ggsave(filename = here("workflow/figures/s2.pdf"), width = 13, height = 10, dpi = 300)

