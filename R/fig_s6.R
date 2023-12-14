library(tidyverse)
library(here)

# saved as rds to keep factor order
load(here("data/jaccard_index.rds"))


fig_s6_data |>
  ggplot(aes(id1, id2, fill = jac)) +
  geom_tile() +
  scale_fill_viridis_c(
    option = "magma",
    labels = scales::percent_format()
  ) +
  geom_text(color = "white", aes(label = jac), size = 1.5) +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1)
  ) +
  labs(
    y = "",
    x = "",
    fill = "Jaccard Index"
  )



ggsave(
  here("workflow/figures/s6.pdf"),
  dpi = 300, width = 13, height = 10
)
